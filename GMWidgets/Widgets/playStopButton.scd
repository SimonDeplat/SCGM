(
//------//
// CORE //
init: { |self|
	// Implement signal system
	~gmDefs.implSignals(self);

	self[\view] = GMPlayButton()
	.action_({ |isPlaying|
		if(isPlaying) {
			self.emitSignal(\_play);
		} {
			self.emitSignal(\_stop);
		};
	})
	.onClose_({
		if(self[\removed].not) {
			self[\view] = nil;
			self.doRemove;
		};
	});
	self
},

connectPlayer: { |self, player|
	self.connectSignal(
		\_play,
		{ player.doPlay; },
		self
	);
	self.connectSignal(
		\_stop,
		{ player.doStop; },
		self
	);
	player.connectSignal(
		\_playing,
		{ self.setPlaying(true); },
		self
	);
	player.connectSignal(
		\_stopped,
		{ self.setPlaying(false); },
		self
	);
	self
},

//---------//
// PROXIES //
setPlaying: { |self, boolean|
	self[\view].setPlaying(boolean);
	self
},

mode: { |self, mode|
	self[\view].mode_(mode);
	self
},

symbolRatio: { |self, ratio|
	self[\view].symbolRatio_(ratio);
	self
},

displayFrame: { |self, boolean|
	self[\view].displayFrame_(boolean);
	self
},

setMaxWidth: { |self, width|
	self[\view].maxWidth_(width);
	self
},

getMaxWidth: { |self|
	self[\view].maxWidth
},

setMaxHeight: { |self, height|
	self[\view].maxHeight_(height);
	self
},

getMaxHeight: { |self|
	self[\view].maxHeight
},

//-------//
// STYLE //
setStyles: { |self, style, textStyle, widgetStyle|
	self[\view].style_(widgetStyle);
	self
},

//------//
// MISC //
removed: false,
doRemove: { |self|
	if(self[\view].notNil) {
		self[\removed] = true;
		self[\view].free;
		self[\view].remove;
	};
	self.emitSignal(\_removed);
	self.clear;
},

doFront: { |self|
	CmdPeriod.doOnce({ self.doRemove; });
	self[\view].front;
	self
},
)