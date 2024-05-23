package options;

class VSFourSettingsSubState extends BaseOptionsMenu
{
      public function new()
      {
            title = 'VS Four Settings';
            rpcTitle = 'VS Four Settings Menu'; //for Discord Rich Presence

            //I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
            var option:Option = new Option('Cake At Stake', //Name
                  'If checked, you will participate in CAKE AT STAKE', //Description
                  'cakeAtStake', //Save data variable name
                  'bool'); //Variable type
            addOption(option);

            super();
      }

      function onChangeHitsoundVolume()
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.data.hitsoundVolume);

	function onChangeAutoPause()
		FlxG.autoPause = ClientPrefs.data.autoPause;
}