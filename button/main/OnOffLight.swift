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

// Helper object that can be used to act as a smart switch.
final class OnOffLight {
  var enabled: Bool = true {
    didSet {
      if enabled {
        app_driver_button_up_cb(nil, nil)
      } else {
        app_driver_button_down_cb(nil, nil)
      }
    }
  }

  let app_driver_button_down_cb: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = { arg1, arg2 in
      print("Button down ⬇️")
  }

  let app_driver_button_up_cb: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = { arg1, arg2 in
      print("Button up ⬆️")
  }

  let app_driver_button_single_click_cb: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = { arg1, arg2 in
      guard let arg2 else { return }
      let selfInstance = Unmanaged<OnOffLight>.fromOpaque(arg2).takeUnretainedValue()

      print("Button single click")

      if let light = selfInstance.onOffLight {
        let cluster = esp_matter.cluster.get_shim(light.onOffLight.endpoint, ClusterID<OnOff>.onOff.rawValue)
        var attribute: UnsafeMutablePointer<esp_matter.attribute_t> = esp_matter.attribute.get_shim(cluster, OnOff.AttributeID<OnOff.OnOffState>.state.rawValue)
        var val: esp_matter_attr_val_t = esp_matter_invalid(nil)

        esp_matter.attribute.get_val(attribute, &val)
        print("val: \(val.val.b)")
        val.val.b = !val.val.b
        print("new val: \(val.val.b)")
        // esp_matter.attribute.update_shim(UInt16(MatterOnOffLight.deviceTypeId), ClusterID<OnOff>.onOff.rawValue, OnOff.AttributeID<OnOff.OnOffState>.state.rawValue, &val)
        esp_matter.attribute.update_shim(UInt16(esp_matter.endpoint.get_id_shim(light.onOffLight.endpoint)), ClusterID<OnOff>.onOff.rawValue, OnOff.AttributeID<OnOff.OnOffState>.state.rawValue, &val)
        esp_matter.attribute.get_val(attribute, &val)
        print("updated val: \(val.val.b)")
      }

      /* From badge demo app driver
          uint16_t endpoint_id = light_endpoint_id;
          uint32_t cluster_id = OnOff::Id;
          uint32_t attribute_id = OnOff::Attributes::OnOff::Id;

          attribute_t *attribute = attribute::get(endpoint_id, cluster_id, attribute_id);

          esp_matter_attr_val_t val = esp_matter_invalid(NULL);
          attribute::get_val(attribute, &val);
          val.val.b = !val.val.b;
          attribute::update(endpoint_id, cluster_id, attribute_id, &val);
    */
  }

  let app_driver_button_double_click_cb: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = { arg1, arg2 in
      print("Button double click")
  }

  let app_driver_button_long_press_start_cb: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = { arg1, arg2 in
      print("Button long press start")
  }

  let app_driver_button_long_press_hold_cb: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = { arg1, arg2 in
      print("Button long press hold")
  }

  var handle: button_handle_t
  private var onOffLight: Matter.OnOffLight?

  init(_ onOffLight: Matter.OnOffLight) {
    self.onOffLight = onOffLight
    var config = button_driver_get_config() // Defined at the target level. Returns the configuration parameters for the given button (in this case, there's only one)
    let handle = iot_button_create(&config) // Initialize the button driver with the given parameters
    guard let handle else { fatalError("Failed to initialize handle") }
    self.handle = handle

    // Register callbacks for when the button is pressed, the callbacks are in this class
    iot_button_register_cb(handle, BUTTON_PRESS_DOWN, app_driver_button_down_cb, nil)
    iot_button_register_cb(handle, BUTTON_PRESS_UP, app_driver_button_up_cb, nil)
    iot_button_register_cb(handle, BUTTON_SINGLE_CLICK, app_driver_button_single_click_cb, Unmanaged.passUnretained(self).toOpaque())
    iot_button_register_cb(handle, BUTTON_DOUBLE_CLICK, app_driver_button_double_click_cb, nil)
    iot_button_register_cb(handle, BUTTON_LONG_PRESS_START, app_driver_button_long_press_start_cb, nil)
    iot_button_register_cb(handle, BUTTON_LONG_PRESS_HOLD, app_driver_button_long_press_hold_cb, nil)
  }
}
