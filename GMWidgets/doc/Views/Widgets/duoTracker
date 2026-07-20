### Duo Tracker

A probabilist tracker intended to drive a rhythm. Manipulates an Array of Floats between 0 and 1.

Wraps GMDuoSequencer (Graphical Module).

#### Methods

|method|args|description & notes|
|:---:|:---:|---|
~gmWidgets.getDuoTracker;||Global getter.
setValues|Array values| An Array of Floats, between 0 and 1.
porbabilities|Array probabilites|An Array of Floats, between 0 and 1, that indicates which set of probabilites are available.
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
var duoTracker, duoTrackerAction;
var duoTrackerProbabilities;
var duoTrackerValues;

duoTrackerProbabilities = [0, 0.25, 0.5, 0.75, 1];
duoTrackerValues = [0, 0, 0, 0, 0, 0, 0, 0];

duoTracker = ~gmWidgets.getDuoTracker
.probabilities(duoTrackerProbabilities)
.setValues(duoTrackerValues)
.connectSignal(
	\_valuesChanged, { |values|
		duoTrackerValues = values;
		duoTrackerValues.postln;
	}
);
```