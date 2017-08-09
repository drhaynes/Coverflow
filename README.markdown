# Coverflow Implementation using UICollectionView

This is an iOS project that implements Coverflow with `UICollectionView` and a custom `UICollectionViewLayout`

![Coverflow screenshot, landscape orientation](./screenshots/coverflow-screenshot-landscape.png)

### CInterpolator

`CInterpolator` is simlar to `CAKeyFrameAnimation` only more generic. You can use it for arbitrary linear interpolation between any key and value.

#### Known Issues

* Need to properly deal with aspect fill/fit images.
* The "Gloom" layer doesn't do a very good job with alpha backgrounds.
* Aliasing is very obvious on straight edges when rotated.
* Shadow needs to be longer to deal with perspective transform. See next item.
* Need to specify manually the Y position of cells so that we can force cells to draw offscreen (for shadows). Or just rely on UIKit's ability to not clip to bounds.

