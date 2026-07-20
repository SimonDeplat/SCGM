### Button

A simple button that can display text or svg.

Wraps GMButton (Graphical Module).

#### Methods

|method|args|description & notes|
|:---:|:---:|---|
~gmWidgets.getButton;||Global getter.
string|String text
fontRatio|Float ratio|Relative to the button size. Usually between 0 and 1.
maxFontSize|Integer pixelSize
svg|String path|Takes an absolute path to a file.
svgRatio|Float ratio|Relative to the button size. Usually between 0 and 1. Aspect is kept.
orientation|Symbol orientation|`\right`, `\top`, `\left` or `\bottom`. Indicates the text orientation. Doesn't affect the SVG.
displayFrame|Boolean displayFrame|Wether to draw the widget background.

#### Signals

|signal|args|description & notes|
:---:|:---:|---|
\\_buttonPressed|
\\_removed|

#### Template

```
var button, buttonAction;

buttonAction = { |state|
	"hello world".postln;
};

button = ~gmWidgets.getButton
.string("click me")
.maxFontSize(32)
.connectSignal(
	\_buttonPressed,
	buttonAction
);
```