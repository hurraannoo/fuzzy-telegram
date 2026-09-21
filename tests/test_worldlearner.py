"""Lua 5.1 behaviour checks; UI doubles do not replace in-game visual testing."""
from pathlib import Path
import unittest
from lupa.lua51 import LuaRuntime

ROOT=Path(__file__).resolve().parents[1]
ADDON=ROOT/'WorldLearner'

class WorldLearnerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.lua=LuaRuntime()
        cls.lua.execute((ROOT/'tests/wow_mock.lua').read_text(encoding='utf-8'))
        load=cls.lua.eval('function(code) local f,e=loadstring(code); assert(f,e); f("WorldLearner",W) end')
        for line in (ADDON/'WorldLearner.toc').read_text().splitlines():
            if line and not line.startswith('#'): load((ADDON/line).read_text(encoding='utf-8'))
        cls.lua.execute('for _,f in ipairs(frames) do if f.events.ADDON_LOADED then driver=f end end; driver.scripts.OnEvent(driver,"ADDON_LOADED","WorldLearner")')

    def setUp(self):
        self.lua.execute('W.Reset(); W.HideCard(); GameTooltip:Hide(); GameTooltip.itemLink=nil; GameTooltip.itemName=nil; GameTooltip.unit=nil; GameTooltip.unitName=nil; shift=false; alt=false; ctrl=false; combat=false; player=false; W.card.mouseOver=false')

    def check(self,code): self.lua.execute(code)

    def test_bilingual_data_and_segmentation(self):
        self.check('''local r=W.Resolve("npc",68,"暴风城卫兵")
            assert(r.en=="Stormwind City Guard")
            assert(W.Layers(W.Tokenize(r.cn)):find("Bàofēng"))
            local tokens=W.Tokenize("野猪"); assert(tokens[1].known)
            assert(W.Resolve("item",25,"破损的短剑").en=="Worn Shortsword")''')

    def test_id_parsing(self):
        self.check('''assert(W.NpcID("Creature-0-123-0-1-68-0000000001")==68)
            assert(W.NpcID("Vehicle-0-123-0-1-68-0000000001")==68)
            assert(W.NpcID("Player-123-00000001")==nil)
            assert(W.NpcID(nil)==nil)
            assert(W.ItemID("|cff00ff00|Hitem:25:0:0|h[Test]|h|r")==25)''')

    def test_shift_after_tooltip_and_sticky_transfer(self):
        self.check('''GameTooltip.unit="mouseover"; GameTooltip.unitName="Stormwind City Guard"
            guid="Creature-0-1-0-1-68-1"; GameTooltip:Show()
            W.Tick(); assert(not W.card:IsShown())
            shift=true; W.Tick(); assert(W.card:IsShown() and W.current.id==68)
            GameTooltip:Hide(); W.Tick(); assert(W.card:IsShown())
            W.card.mouseOver=true; W.Tick(); assert(W.card:IsShown())
            shift=false; W.Tick(); assert(not W.card:IsShown())''')

    def test_inventory_and_player_exclusion(self):
        self.check('''shift=true; GameTooltip.itemName="Worn Shortsword"; GameTooltip.itemLink="item:25:0"
            GameTooltip:Show(); W.Tick(); assert(W.current.kind=="item" and W.current.cn=="破损的短剑")
            W.SetOption("items",false); assert(not W.card:IsShown())
            W.Tick(); assert(not W.card:IsShown())
            GameTooltip.itemLink=nil; GameTooltip.unit="mouseover"; GameTooltip.unitName="A player"
            guid="Creature-0-1-0-1-68-1"; player=true; W.Tick(); assert(not W.card:IsShown())''')

    def test_unknown_and_reused_ids(self):
        self.check('''local r=W.Resolve("npc",68,"自定义卫兵")
            assert(r.cn=="自定义卫兵" and r.en=="")
            assert(r.status=="Name differs from Classic data")
            r=W.Resolve("item",999999,"未知物品"); assert(r.en=="")
            W.SetOption("showMissing",false); assert(W.Resolve("item",999999,"未知物品")==nil)''')

    def test_settings_validation_and_persistence(self):
        self.check('''W.SetOption("chineseSize",99); assert(W.db.chineseSize==32)
            W.SetOption("modifier","BAD"); assert(W.db.modifier=="SHIFT")
            W.SetOption("chinese",false); W.SetOption("pinyin",false); W.SetOption("english",false)
            assert(W.db.chinese)
            W.SetOption("width",420); W.Initialize(); assert(W.db.width==420)
            W.db.opacity=0/0; W.db.minimapAngle=9999; W.db.modifier="BAD"; W.Initialize()
            assert(W.db.opacity==.96 and W.db.minimapAngle==360 and W.db.modifier=="SHIFT")''')

    def test_modifiers_and_combat(self):
        self.check('''W.SetOption("modifier","ALT"); shift=true; assert(not W.Active())
            alt=true; assert(W.Active()); alt=false
            W.SetOption("modifier","CTRL"); ctrl=true; assert(W.Active())
            W.SetOption("modifier","ALWAYS"); ctrl=false; assert(W.Active())
            W.Preview(); assert(W.card:IsShown()); W.SetOption("combat",false)
            combat=true; W.Tick(); assert(not W.card:IsShown())''')

    def test_pin_and_nonsticky(self):
        self.check('''W.Preview(); W.Tick(); assert(W.card:IsShown())
            W.pin.scripts.OnClick(); W.Tick(); assert(not W.card:IsShown())
            shift=true; W.SetOption("sticky",false)
            GameTooltip.itemName="Worn Shortsword"; GameTooltip.itemLink="item:25:0"; GameTooltip:Show()
            W.Tick(); assert(W.card:IsShown()); GameTooltip:Hide(); W.Tick(); assert(not W.card:IsShown())''')

    def test_word_hover_and_menu(self):
        self.check('''W.Preview(); W.ShowWord(W.tokens[1]); assert(W.wordTip:IsShown())
            assert(#W.wordTip.lines>=3)
            W.wordTip:Hide(); W.SetOption("wordHover",false); W.ShowWord(W.tokens[1])
            assert(not W.wordTip:IsShown())
            W.settings:Hide(); W.minimapButton.scripts.OnClick(nil,"LeftButton"); assert(W.settings:IsShown())
            W.minimapButton.scripts.OnClick(nil,"RightButton"); assert(not W.db.enabled)
            assert(not W.card:IsShown())
            W.SetOption("minimap",false); assert(not W.minimapButton:IsShown())
            SlashCmdList.WORLDLEARNER("minimap"); assert(W.minimapButton:IsShown())''')

    def test_size_extremes_and_wrapping(self):
        self.check('''W.SetOption("width",260); W.SetOption("chineseSize",32)
            W.Preview(); assert(W.card:GetHeight()>120)
            assert(W.card:GetHeight()<600)
            for _,b in ipairs(W.tokens) do
                if b:IsShown() then assert(b:GetHeight()>=b.label:GetStringHeight()) end
            end''')

if __name__=='__main__': unittest.main(verbosity=2)
