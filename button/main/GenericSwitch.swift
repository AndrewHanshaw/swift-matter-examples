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
final class GenericSwitch {
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

  var handle: button_handle_t

  init() {
    var config = button_driver_get_config() // Defined at the target level. Returns the configuration parameters for the given button (in this case, there's only one)
    let handle = iot_button_create(&config) // Initialize the button driver with the given parameters
    guard let handle else { fatalError("Failed to initialize handle") }

    // Register callbacks for when the button is pressed, the callbacks are in this class
    iot_button_register_cb(handle, BUTTON_PRESS_DOWN, app_driver_button_down_cb, nil)
    iot_button_register_cb(handle, BUTTON_PRESS_UP, app_driver_button_up_cb, nil)
    self.handle = handle
  }
}
