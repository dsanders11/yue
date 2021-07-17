// Copyright 2016 Cheng Zhao. All rights reserved.
// Use of this source code is governed by the license that can be found in the
// LICENSE file.

#include "nativeui/app.h"

#include "base/base_paths.h"
#include "base/path_service.h"
#include "base/strings/sys_string_conversions.h"
#include "nativeui/mac/nu_application_delegate.h"
#include "nativeui/menu_bar.h"

namespace nu {

bool App::IsBundled() const {
  return [[NSBundle mainBundle] bundleIdentifier];
}

void App::SetApplicationMenu(scoped_refptr<MenuBar> menu) {
  application_menu_ = std::move(menu);
  [NSApp setMainMenu:application_menu_->GetNative()];
}

MenuBar* App::GetApplicationMenu() const {
  return application_menu_.get();
}

void App::SetDockBadgeLabel(const std::string& text) {
  [[NSApp dockTile] setBadgeLabel:base::SysUTF8ToNSString(text)];
}

std::string App::GetDockBadgeLabel() const {
  return base::SysNSStringToUTF8([[NSApp dockTile] badgeLabel]);
}

void App::Activate(bool force) {
  [NSApp activateIgnoringOtherApps:force];
}

void App::Deactivate() {
  [NSApp deactivate];
}

bool App::IsActive() const {
  return [NSApp isActive];
}

void App::SetActivationPolicy(ActivationPolicy policy) {
  NSApplicationActivationPolicy p = NSApplicationActivationPolicyRegular;
  switch (policy) {
    case ActivationPolicy::Regular:
      p = NSApplicationActivationPolicyRegular;
      break;
    case ActivationPolicy::Accessory:
      p = NSApplicationActivationPolicyAccessory;
      break;
    case ActivationPolicy::Prohibited:
      p = NSApplicationActivationPolicyProhibited;
      break;
  }
  [NSApp setActivationPolicy:p];
}

App::ActivationPolicy App::GetActivationPolicy() const {
  switch ([NSApp activationPolicy]) {
    case NSApplicationActivationPolicyRegular:
      return ActivationPolicy::Regular;
    case NSApplicationActivationPolicyAccessory:
      return ActivationPolicy::Accessory;
    case NSApplicationActivationPolicyProhibited:
      return ActivationPolicy::Prohibited;
  }
}

std::string App::PlatformGetName() const {
  NSString* key = static_cast<NSString*>(kCFBundleNameKey);
  NSString* name = [NSBundle mainBundle].infoDictionary[key];
  if (name)
    return base::SysNSStringToUTF8(name);
  base::FilePath path;
  if (base::PathService::Get(base::FILE_EXE, &path))
    return path.BaseName().RemoveExtension().value();
  return "Yue";
}

}  // namespace nu
