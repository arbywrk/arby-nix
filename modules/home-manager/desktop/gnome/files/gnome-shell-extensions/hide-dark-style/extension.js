import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

// Replaces gnomeExtensions.quick-settings-tweaker, which duplicated the "Do
// Not Disturb" toggle when forced to run past its declared shell-version
// support (48/49) on GNOME Shell 50.4 -- its own bundled default toggle
// order list matches Do Not Disturb by a stale constructor name
// ("DndQuickToggle") that no longer exists in js/ui/status/doNotDisturb.js,
// so it fell out of that extension's reordering logic entirely.
//
// Removes the toggle from its parent rather than calling .hide() on it --
// .hide() doesn't survive a real logout/login (something else in the
// quick settings menu re-asserts visibility on it), and GNOME's own
// ReloadExtension D-Bus method is a hard no-op ("ReloadExtension is
// deprecated and does not work", straight from js/ui/shellDBus.js), so
// there's no way to iterate short of a full session restart each time.
// remove_child is the safer bet since it doesn't depend on nothing else
// ever re-asserting visibility on its children.
//
// Main.panel.statusArea.quickSettings._darkMode is the built-in
// DarkModeStatus.Indicator, and its single quickSettingsItems entry is the
// DarkModeToggle QuickToggle widget itself.
export default class HideDarkStyleExtension extends Extension {
    enable() {
        this._toggle = Main.panel.statusArea.quickSettings._darkMode?.quickSettingsItems[0];
        this._toggleParent = this._toggle?.get_parent();
        this._toggleParent?.remove_child(this._toggle);
    }

    disable() {
        if (this._toggle && this._toggleParent)
            this._toggleParent.add_child(this._toggle);
        this._toggle = null;
        this._toggleParent = null;
    }
}
