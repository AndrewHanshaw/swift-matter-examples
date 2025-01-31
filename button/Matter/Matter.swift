//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

enum Matter {}

extension Matter {
  class Node {
    var identifyHandler: (() -> Void)? = nil

    var endpoints: [Endpoint] = []

    func addEndpoint(_ endpoint: Endpoint) {
      endpoints.append(endpoint)
    }

    // swift-format-ignore: NeverUseImplicitlyUnwrappedOptionals
    // This is never actually nil after init(), and inside init we want to form a callback closure that references self.
    var innerNode: RootNode!

    init() {
      // Initialize persistent storage.
      nvs_flash_init()

      // For now, leak the object, to be able to use local variables to declare it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)

      // Create the actual root node object, wire up callbacks.
      let root = RootNode(
        attribute: self.eventHandler,
        identify: { _, _, _, _ in self.identifyHandler?() })
      guard let root else {
        fatalError("Failed to setup root node.")
      }
      self.innerNode = root
    }

    func eventHandler(
      type: MatterAttributeEvent, endpoint: __idf_main.Endpoint,
      cluster: Cluster, attribute: UInt32,
      value: UnsafeMutablePointer<esp_matter_attr_val_t>?
    ) {
      guard type == .didSet else { 
        print("failed guard in eventhandler")
        return }
      guard let e = self.endpoints.first(where: { $0.id == endpoint.id }) else {
        print("failed guard in eventhandler")
        return
      }
      let value: Int = Int(value?.pointee.val.u64 ?? 0)
      guard let a = Endpoint.Attribute(cluster: cluster, attribute: attribute)
      else { 
        print("failed guard in eventhandler")
        return }
      print("setting up event handler")
      e.eventHandler?(Endpoint.Event(type: type, attribute: a, value: value))
    }
  }
}

extension Matter {
  class Endpoint {
    init(node: Node) {
      // For now, leak the object, to be able to use local variables to declare it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)
    }

    var id: Int = 0

    var eventHandler: ((Event) -> Void)? = nil

    enum Attribute {
      case onOff
      case unknown(UInt32)

      init?(cluster: Cluster, attribute: UInt32) {
        if let _ = cluster.as(OnOff.self) {
          switch attribute {
          case OnOff.AttributeID<OnOff.OnOffState>.state.rawValue: self = .onOff
          default: return nil
          }
        } else {
          self = .unknown(attribute)
        }
      }
    }

    struct Event {
      var type: MatterAttributeEvent
      var attribute: Attribute
      var value: Int
    }
  }
}

// Set up the endpoint. Endpoint parameters from esp-matter/components/esp_matter/esp_matter_endpoint.cpp
// extension Matter {
//   class OnOffLight: Endpoint {
//     override init(node: Node) {
//       super.init(node: node)

//       print("Setting up OnOffLight Endpoint")
//       var onOffLightConfig = esp_matter.endpoint.on_off_light.config_t()

//       let onOffLight = MatterOnOffLight(
//         node.innerNode, configuration: onOffLightConfig)
//       self.id = Int(onOffLight.id)
//     }
//   }
// }
extension Matter {
  class OnOffLight: Endpoint {
    var onOffLight: MatterOnOffLight

    override init(node: Node) {
      print("Setting up OnOffLight Endpoint")
      var onOffLightConfig = esp_matter.endpoint.on_off_light.config_t()

      self.onOffLight = MatterOnOffLight(node.innerNode, configuration: onOffLightConfig)

      super.init(node: node)

      self.id = Int(onOffLight.id)
    }
  }
}

extension Matter {
  class Application {
    var rootNode: Node? = nil

    init() {
      // For now, leak the object, to be able to use local variables to declare
      // it. We don't expect this object to be created and destroyed repeatedly.
      _ = Unmanaged.passRetained(self)
    }

    func start() {
      func callback(
        event: UnsafePointer<chip.DeviceLayer.ChipDeviceEvent>?, context: Int
      ) {
        // Ignore callback if event not set.
        guard let event else { return }
        switch Int(event.pointee.Type) {
        case chip.DeviceLayer.DeviceEventType.kFabricRemoved:
          recomissionFabric()
        default: break
        }
      }
      print("Calling esp_matter.start")
      var err = esp_matter.start(callback, 0)
      print("err: \(err)")
    }
  }
}

func print(_ a: Matter.Endpoint.Attribute) {
  switch a {
  case .onOff: print("onOff")
  case .unknown: print("unknown")
  }
}
