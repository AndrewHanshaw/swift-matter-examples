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

#include "BridgingHeader.h"

uint16_t esp_matter::endpoint::get_id_shim(esp_matter::endpoint_t* endpoint) {
  return get_id(endpoint);
}

esp_err_t esp_matter::attribute::set_callback_shim(callback_t_shim callback) {
  return set_callback((callback_t)callback);
}

esp_matter::cluster_t *esp_matter::cluster::get_shim(esp_matter::endpoint_t *endpoint, unsigned int cluster_id) {
  return get(endpoint, (uint32_t)cluster_id);
}

esp_matter::attribute_t *esp_matter::attribute::get_shim(esp_matter::cluster_t *cluster, unsigned int attribute_id) {
  return get(cluster, (uint32_t)attribute_id);
}

esp_err_t esp_matter::attribute::update_shim(unsigned short endpoint_id, unsigned int cluster_id, unsigned int attribute_id, esp_matter_attr_val_t *val) {
  return update(endpoint_id, cluster_id, attribute_id, val);
}

esp_err_t esp_matter::cluster::switch_cluster::feature::momentary_switch::add_shim(cluster_t *cluster) {
  return add(cluster);
}

esp_err_t esp_matter::cluster::switch_cluster::feature::action_switch::add_shim(cluster_t *cluster) {
  return add(cluster);
}

esp_err_t esp_matter::cluster::switch_cluster::feature::momentary_switch_multi_press::add_shim(cluster_t *cluster, config_t *config) {
  return add(cluster, config);
}

esp_matter::lock::status_t esp_matter::lock::chip_stack_lock_shim(unsigned int ticks_to_wait) {
  return chip_stack_lock((uint32_t)ticks_to_wait);
}

esp_err_t esp_matter::lock::chip_stack_unlock_shim() {
  return chip_stack_unlock();
}

esp_err_t esp_matter::client::cluster_update_shim(uint16_t local_endpoint_id, esp_matter::client::request_handle_t *req_handle) {
  return cluster_update(local_endpoint_id, req_handle);
}

void recomissionFabric() {
  if (chip::Server::GetInstance().GetFabricTable().FabricCount() == 0) {
    chip::CommissioningWindowManager & commissionMgr = chip::Server::GetInstance().GetCommissioningWindowManager();
    constexpr auto kTimeoutSeconds = chip::System::Clock::Seconds16(300);
    if (!commissionMgr.IsCommissioningWindowOpen()) {
      commissionMgr.OpenBasicCommissioningWindow(kTimeoutSeconds, chip::CommissioningWindowAdvertisement::kDnssdOnly);
    }
  }
}
