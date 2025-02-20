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

@_cdecl("app_main")
func main() {
  print("Button running")

  // (1) Create a Matter root node
  let rootNode = Matter.Node()
  rootNode.identifyHandler = {
    print("identify")
  }

  // (2) Create an "OnOffLight" endpoint
  print ("Creating OnOffLight endpoint in Main.swift")
  let onOffLightEndpoint = Matter.OnOffLight(node: rootNode)
  onOffLightEndpoint.eventHandler = { event in
    print("onOffLightEndpoint.eventHandler:")
    print(event.attribute)
    print(event.value)

    switch event.attribute {
    case .onOff:
      print("onoff event!")

    default:
      break
    }
  }

  let onOffLight = OnOffLight(onOffLightEndpoint)

  // (3) Add the endpoint to the node
  rootNode.addEndpoint(onOffLightEndpoint)

  /* Set OpenThread platform config */
  set_openthread_platform_config_shim();

  // Set wifi mode to power save
  esp_wifi_set_ps(WIFI_PS_MIN_MODEM);

  // (4) Provide the node to a Matter application and start it
  let app = Matter.Application()
  app.rootNode = rootNode
  app.start()

  // Keep local variables alive. Workaround for issue #10
  // https://github.com/apple/swift-matter-examples/issues/10
  while true {
    // // onOffLight.enabled.toggle()
    // let cluster = esp_matter.cluster.get_shim(onOffLightEndpoint.onOffLight.endpoint, ClusterID<OnOff>.onOff.rawValue)
    // var attribute: UnsafeMutablePointer<esp_matter.attribute_t> = esp_matter.attribute.get_shim(cluster, OnOff.AttributeID<OnOff.OnOffState>.state.rawValue)
    // var val: esp_matter_attr_val_t = esp_matter_invalid(nil)

    // esp_matter.attribute.get_val(attribute, &val)
    // print("val: \(val.val.b)")
    // val.val.b = !val.val.b
    // // esp_matter.attribute.update(UInt16(MatterOnOffLight.deviceTypeId), ClusterID<OnOff>.onOff.rawValue, OnOff.AttributeID<OnOff.OnOffState>.state.rawValue, &val)
    // esp_matter.attribute.update_shim(UInt16(MatterOnOffLight.deviceTypeId), ClusterID<OnOff>.onOff.rawValue, OnOff.AttributeID<OnOff.OnOffState>.state.rawValue, &val)
    // // esp_matter.attribute.update(UInt16(MatterOnOffLight.deviceTypeId), UInt32(ClusterID<OnOff>.onOff.rawValue))
    // // esp_matter.attribute.set_val(attribute, &val)
    sleep(10)
  }
}
