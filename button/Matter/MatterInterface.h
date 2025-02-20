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

// GNU C++ interfaces do not work well with Swift for certain types, so let's use some simple C++ shims.
// For example, uint32_t gets imported as UInt and not CUnsignedLong (as defined in ESP IDF).
namespace esp_matter {
  namespace endpoint {
    uint16_t get_id_shim(endpoint_t *endpoint);
  }
  namespace attribute {
    typedef esp_err_t (*callback_t_shim)(callback_type_t type, uint16_t endpoint_id, unsigned int cluster_id,
                                         unsigned int attribute_id, esp_matter_attr_val_t *val, void *priv_data);
    esp_err_t set_callback_shim(callback_t_shim callback);
  }

  namespace cluster {
    cluster_t *get_shim(endpoint_t *endpoint, unsigned int cluster_id);

    namespace switch_cluster {
      namespace feature {
        namespace momentary_switch {
          esp_err_t add_shim(cluster_t *cluster);
        }

        namespace action_switch {
          esp_err_t add_shim(cluster_t *cluster);
        }

        namespace momentary_switch_multi_press {
          esp_err_t add_shim(cluster_t *cluster, config_t *config);
        }
      }
    }
  }

  namespace attribute {
    attribute_t *get_shim(cluster_t *cluster, unsigned int attribute_id);

    esp_err_t update_shim(unsigned short endpoint_id, unsigned int cluster_id, unsigned int attribute_id, esp_matter_attr_val_t *val);
  }

  namespace lock {
    status_t chip_stack_lock_shim(unsigned int ticks_to_wait);

    esp_err_t chip_stack_unlock_shim();
  }

  namespace client {
    esp_err_t cluster_update_shim(uint16_t local_endpoint_id, request_handle_t *req_handle);
  }
}

// Recomissioning causes failures with reference semantics so this is done as a function implemented in C++.
// Ideally this would be done by changing some of the headers in ESP Matter to have proper Swift annotations.
void recomissionFabric();

esp_err_t set_openthread_platform_config_shim();