(
init: { |self|
	self[\orientation] = \vertical;
	self[\size] = 1;
	self[\index] = 0;
	self[\items] = List(0);
	self[\menu] = ~gmWidgets.getMenu;

	self[\downButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\arrowTop))
	.connectSignal(
		\_buttonPressed, {
			if(self[\index] > 0) {
				self[\index] = self[\index] - 1;
			};
			self.updateViews;
		},
		self
	);
	self[\zoomButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\sub))
	.connectSignal(
		\_buttonPressed, {
			if(self[\size] > 1) {
				self[\size] = self[\size] - 1;
			};
			self.updateViews;
		},
		self
	);
	self[\dezoomButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\add))
	.connectSignal(
		\_buttonPressed, {
			if(self[\size] < self[\items].size) {
				self[\size] = self[\size] + 1;
				if(
					(self[\index] + self[\size])
					> self[\items].size
				) {
					self[\index] = self[\items].size - self[\size];
				};
			};
			self.updateViews;
		},
		self
	);
	self[\upButton] = self[\menu].addButton
	.svg(~gmWidgets.getIcon(\arrowBot))
	.connectSignal(
		\_buttonPressed, {
			if((self[\index] + self[\size]) < self[\items].size) {
				self[\index] = self[\index] + 1;
			};
			self.updateViews;
		},
		self
	);
	self[\layout] = VLayout()
	.spacing_(4)
	.margins_(0);
	self[\container] = UserView()
	.layout_(self[\layout]);
	self[\view] = UserView()
	.layout_(
		HLayout()
		.spacing_(8)
		.margins_(2)
		.add(self[\container], 9)
		.add(self[\menu][\view], 1)
	);
	self
},

addItem: { |self, item, display = false|
	self[\items].add(item);
	self[\layout].add(item[\view]);
	if(
		(
			((self[\items].size - 1) >= self[\index])
			and:
			{
				((self[\items].size - 1) <=
					(self[\index] + self[\size] - 1))
			}
		)
		or:
		{ display }
	) {
		if(display) {
			self[\index] = self[\items].size - self[\size];
			self.updateViews;
		} {
			item[\view].visible_(true);
		};
	} {
		item[\view].visible_(false);
	};
	self
},

updateViews: { |self|
	self[\items].do({ |item, index|
		if(
			(index >= self[\index])
			and:
			{ index <= (self[\index] + self[\size] - 1) }
		) {
			item[\view].visible_(true);
		} {
			item[\view].visible_(false);
		};
	});
},

setOrientation: { |self, orientation|
	if(self[\orientation] != orientation) {
		self[\orientation] = orientation;
		if(orientation == \horizontal) {
			self[\layout] = VLayout()
			.spacing_(4)
			.margins_(0);
			self[\view] = UserView()
			.layout_(
				HLayout()
				.spacing_(8)
				.margins_(2)
				.add(self[\container], 9)
				.add(self[\menuView], 1)
			);
			self[\upButton].svg(~gmWidgets.getIcon(\arrowBot));
			self[\downButton].svg(~gmWidgets.getIcon(\arrowTop));
		} {
			self[\layout] = HLayout()
			.spacing_(4)
			.margins_(0);
			self[\view] = UserView()
			.layout_(
				VLayout()
				.spacing_(8)
				.margins_(2)
				.add(self[\container], 9)
				.add(self[\menuView], 1)
			);
			self[\upButton].svg(~gmWidgets.getIcon(\arrowRight));
			self[\downButton].svg(~gmWidgets.getIcon(\arrowLeft));
		};
		self[\items].do({ |view|
			self[\layout].add(view[\view]);
		});
		self[\container].layout_(self[\layout]);
	};
	self
},

visible: { |self, visible|
	self[\view].visible_(visible);
},
)