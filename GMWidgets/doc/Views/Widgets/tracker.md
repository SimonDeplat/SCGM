### Duo Tracker

A deterministic tracker intended to drive a rhythm. Manipulates an Array of Integers, either 0 or 1.

Wraps GMSequencer (Graphical Module).

#### Methods

|method|args|description & notes|
|:---:|:---:|---|
~gmWidgets.getDuoTracker;||Global getter.
setValues|Array values| An Array of Integers, either 0 or 1.
beat|Integer beat| Highlights the nth value. Set to 0 to disable.
highlights|Array highlights| Highlights values to make the main rhythm more apparent.
displayHighlights|Boolean displayHighlights|Whether to draw highlights.
symbol|Symbol symbol|`\circle`, `\square`, or `\diamond`.
symbolRatio|Float ratio|Relative to the widget size.
displayFrame|Boolean displayFrame|Wether to draw the widget background.

#### Signals

|signal|args|description & notes|
:---:|:---:|---|
\\_valuesChanged|Array values|
\\_removed|

#### Template

```
var tracker, trackerAction;
var trackerValues;

trackerValues = [0, 0, 0, 0, 0, 0, 0, 0];

tracker = ~gmWidgets.getTracker
.setValues(trackerValues)
.connectSignal(
	\_valuesChanged, { |values|
		trackerValues = values;
		trackerValues.postln;
	}
);
```