<h1 align="center">EPWatch</h1>

<div align="center">
<img alt="EPWatch" height="125" src="./Resources/Assets.xcassets/AppIcon.appiconset/icon.png">
</div>

<p align="center">
App displaying the current electricity price,<br> with widgets for Apple Watch, iPhone and iPad.
</p>
<br>

EPWatch is an open source app that allows you to see the current electricity price on your Apple Watch, iPhone and iPad.<br>
I created this app mainly for the Apple Watch, as I wanted such an app for myself and couldn't find one at the time. I added iPhone/iPad support because it was easy and I wanted try out the new iOS 16 lock screen widgets.

## Download

EPWatch is available on the [App Store](https://apps.apple.com/se/app/elpriset-widget/id1644399828), currently only in Sweden. Hopefully in more countries when I find the time.

[![Elpriset - Widget](./Resources/Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917.svg)](https://apps.apple.com/se/app/elpriset-widget/id1644399828)

## Build

-   Obtain an API token from https://transparency.entsoe.eu/ (you need to create an account, but it's free).
-   Hit Build & Run

## Issues

Feel free to create an issue for any bugs, feature requests or questions.

## Resources

I found [this reddit answer](https://www.reddit.com/r/sweden/comments/r50v12/comment/ik9kif9/) very helpful when I got started. I still don't understand the [entsoe documentation](https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html) on how to construct the `in_Domain`/`out_Domain` values of the query :)
