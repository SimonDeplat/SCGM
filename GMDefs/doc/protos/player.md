### Player

#### Overview

The *Player* is one of the most important part of the SCGM framework. It somehow mimics a real life orchestra conductor. When a *Player* is assigned to a *Synth*, **the** *Player* **will control the scale and rhythm specifications of the** *Synth*. This allows creating orchestras of *Synths*, that can be started or tuned all at once by updating the *Player*.

A *Player* has a defined **frequency** which usually defines the main key. It can be offset by specifying a tuning value. It also references a scale (using <u>Scale</u>). This ensures controlled *Synths* stay in tune with each other.

A *Player* has a defined **BPM** value, and holds a **rhythm** specification. Internally, it uses a <u>TempoClock</u> and a <u>Routine</u> to play *Synths* scores with synchronized rhythm.

#### Methods

**~gmDefs.getPlayer** : global getter, returns a new instance.

**doPlay** : starts the Player's Routine if not running. Emits a *\\_playing* signal.

**doStop** : stops the Player's Routine if running. Emits a *\\_stopped* signal.

**setFreq** *Number freq* : sets the Player's main frequency. Emits a *\\_freqChanged* signal.

**getFreq** : returns the Player's main frequency.

**setScale** *Scale scale* : sets the Player's main scale. Emits a *\\_scaleChanged* signal.

**getScale** : returns the Player's scale.

**setTuning** *Number tuning* : sets the Player's tuning ratio and updates its frequency. Emits a *\\_tuningChanged* signal, then a *\\\_freqChanged* signal.

**getTuning** : returns the Player's tuning ratio.

**setTuningHz** *Number tuning* : sets the Player's tuning ratio using a frequency and updates the main frequency. This allows to change the reference A (which defaults to 440Hz) easily. Emits a *\\_tuningChanged* signal, then a *\\_freqChanged* signal.

**getTuningHz** : returns the Player's tuning frequency, i.e. its reference A.

**setRhythm** *Array rhythm* : sets the Player's rhythm structure. Emits a *\\_rhythmChanged* signal.

**getRhythm** : returns the Player's rhythm structure.

**setBPM** *Number bpm* : sets the Player's BPM. Emits a *\\_bpmChanged* signal.

**getBPM** : returns the Player's BPM.

**getRate** : returns the Player's BPM rate (BPM / 60).

**doRemove** : stops the <u>Clock</u>, the <u>Routine</u>, emits a *\\_removed* signal, then frees itself.

#### Signals

**\\_playing** : emitted when the <u>Routine</u> is started.

**\\_stopped** : emitted when the <u>Routine</u> is stopped.

**\\_preBeat** : emitted during the <u>Routine</u>, at beat time, before Synths are played.

**\\_beat** : emitted during the <u>Routine</u>, at beat time, triggering the Synths. Its main purpose is internal, use with caution.

**\\_postBeat** : emitted during the <u>Routine</u>, at beat time, after Synths are played. Internally triggers UI refresh calls.

**\\_freqChanged** *Number freq* : emitted when the Player's frequency changed.

**\\_scaleChanged** *Scale scale* : emitted when the Player's scale changed.

**\\_tuningChanged** *Number tuning* : emitted when the Player's tuning changed.

**\\_rhythmChanged** *Array rhythm* : emitted when the Player's rhythm changed.

**\\_bpmChanged** *Number bpm* : emitted when the Player's BPM changed.

**\\_removed** : emitted when the Player is removed.


