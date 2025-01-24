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

  let genericSwitch = GenericSwitch()

  // (1) Create a Matter root node
  let rootNode = Matter.Node()
  rootNode.identifyHandler = {
    print("identify")
  }

  // (2) Create an "GenericSwitch" endpoint
  print ("Creating GenericSwitch endpoint in Main.swift")
  let genericSwitchEndpoint = Matter.GenericSwitch(node: rootNode)
  genericSwitchEndpoint.eventHandler = { event in
    print("genericSwitchEndpoint.eventHandler:")
    print(event.attribute)
    print(event.value)
  }

  // (3) Add the endpoint to the node
  rootNode.addEndpoint(genericSwitchEndpoint)

  // (4) Provide the node to a Matter application and start it
  let app = Matter.Application()
  app.rootNode = rootNode
  app.start()

  // Keep local variables alive. Workaround for issue #10
  // https://github.com/apple/swift-matter-examples/issues/10
  while true {
    // genericSwitch.enabled.toggle()
    sleep(1)
  }
}
