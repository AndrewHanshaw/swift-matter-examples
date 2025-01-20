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
final class OnOffSwitch {
  var enabled: Bool = true {
    didSet { // What to do when the switch is turned on from a controller?
      led_driver_set_power(handle, enabled)
    }
  }

// Need to handle when the connected pin goes high?

  // register_callback() {}

  var handle: button_handle_t

  init() {
    var config = button_driver_get_config() // Defined at the target level. Returns the configuration parameters for the given button (in this case, there's only one)
    let handle = iot_button_create(&config) // Initialize the button driver with the given parameters
    guard let handle else { fatalError("Failed to initialize handle") }
    self.handle = handle
  }
}
