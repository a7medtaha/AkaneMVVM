# CHANGELOG

### 0.18.0

### Changes

- [Observer] `ViewObserver` is a dedicated class.
- [Collection] Replaced data sources with one unique `DataSource` protocol.
- [Collection] Removed template system. Just use regular register(cell) method from tableview/collectionview.

## 0.17.2

### Fixes

- [Component] fixed `ComponentView.componentControllerClass` not called when creating component.

## 0.17.1

### Changes
- [Component] Added `anyViewModel()` getter on `ComponentController`.
- [Command] Allowed `AsyncCommand.completed` closure to escape.

## 0.17.0

### Changes
- [Component] Removed `ComponentViewController`. Replace it with `UIViewController, ComponentController`.
- [View] `ComponentView.bindings(_:viewModel:)` is now generic.

## 0.16.0

### Changes
- Swift 3 support. - [viteinfinite](https://github.com/viteinfinite)
- Moved Bond dependency into a subspec (still included by default).

# 0.15.0

## Changes

- `Command` now expects data instead than the control itself.

## Bugfixes

- Fixed some mispelled delegate methods of `UICollectionViewDelegate`.

# 0.14.0

## Added

- [View] You can access `componentLifecycle` from `ComponentView`.
- [Collection] You can now reload a row/section. Just make your `ComponentViewModel` conform to new `Updatable` protocol.
- [ViewModel] Added `router` property on `ComponentViewModel`. Use it to navigate btw your controllers.
- [Command] Added `AsyncCommand`.

## Enhancements

- [Binding] Simplified internal code, which should be easier to understand.
- [ViewModel] Replaced `ComponentItemViewModel` with `Selectable` and `Unselectable`.

## Bugfixes

- [View] Fixed `componentControllerClass` could not be overriden.
- [Command] Fixed `updateCanExecute` not called into init

# 0.12.0

TL;DR Drastically simplified DataSource protocols for UITableView and UICollectionView.
Now you only have `DataSource*` protocols to use.

## Added

- [Wrapper] added method `convert(_: (Element -> NewElement))` for simple conversions.

## Enhancements

- [Controller] Changed method `didLoad` to `didLoadComponent`. Additionally this method is called every
time the ViewModel is setted.
- [DataSource] Removed `ComponentCollectionView` and `ComponentTableView`.
- [DataSource] Removed `ComponentCollectionViewModel`. Methods moved to `DataSource`.
- [DataSource] Removed `DataType` typealias

## Bugfixes

- [Controller] Fixed a crash with lifecycle when not allocated

# 0.12.0 beta 2

TL;DR Support binding with CollectionView was added. Some important features are missing and will be added in beta 3.
API is globally stable but some changes might happen in further betas.

## Added

- [Collection] Support for CollectionView binding.
- [Template] Support for template coming from storyboard. You can now use enum `Nib(nib)`, `StoryboardId(id)`
or `File()` to load a template from a source.

## Enhancements

- [DataSource] `ItemIdentifier` and `SectionIdentifier` now need to conform to `RawStringRepresentable` instead of `RawStringRepresentable`.
Just add `RawStringRepresentable` to your String enum declaration to make it automatically conform to the protocol.
- [Layout] Uniformized `UICollectionView` and `UITableView` by adding a `layout` attribute to the later one.
- [DataSource] Changed signature of method `tableViewSectionTemplate`.
- [Layout] Renamed `CollectionLayout` and `CollectionAutoLayout` as `TableViewLayout` and `TableViewFlowLayout`.
- [Observer] Allow to return an attribute of an observed property to bind with. Use `observe(observable:attribute:)` method.
- [Converter] Allow to use a `Converter` expecting `A` with a `Optional<A>`.
- [Framework] Added Carthage support -
[viteinfinite](https://github.com/viteinfinite) [#PR8](https://github.com/akane/Akane/pull/8)
- [Doc] Documentation was improved -
[viteinfinite](https://github.com/viteinfinite)
[#PR10](https://github.com/akane/Akane/pull/10)
[#PR11](https://github.com/akane/Akane/pull/11)

## Bugfixes

- [Layout] Fixed `TemplateView` init not marked as public.
- [Component] Fixed crash with optional lifecycle.
- [DataSource] Fixed `DataType` not marked as implicitly unwrapped optional.

# 0.12.0 beta 1

TL;DR Support for binding with TableView was added. Some important features are missing and will be added in beta 2.

## Added

- [Collection] DataSource protocol for table views. It is very similar to the one provided by Apple while emphasis it
- [Collection] View Models protocols to interact with a collection dataset.
- [Collection] TableView templates to register ```ComponentViewModel``` instances on ```UITableView```
- [Collection] TableView layout system
- [Binding] Added `bindTo` on optional `Command`

## Enhancements

- Renamed ```ViewModel``` as ```ComponentViewModel``` for consistency with other related protocols (```ComponentView``` and ```ComponentController```)

# 0.12.0 alpha 2

Akane is now compatible with Xcode 7.1+.

## Added

## Enhancements

- All protocols were re-written in Swift
- ViewComponent was renamed ComponentView
- Presenter was renamed ComponentController

# 0.12.0 alpha

0.12.0 requires iOS8+ and Swift 2.0+.

Also note that due to a bug into Cocoapods 0.39, Akane is not compatible with Xcode 7.1+.

## Added

- "Native" binding. Use the new method ```bindings:viewModel``` from ```ViewComponent``` protocol.
- Command pattern support to communicate between View and ViewModel. Use ```RelayCommand``` or a custom one with ```Command``` protocol.
- Binding converters.

## Enhancements

- Removed deprecated methods. Some are still available and will be removed in future beta releases.
- Made Akane compatible with Swift only.
