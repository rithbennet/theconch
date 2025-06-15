#!/usr/bin/env python3
"""
Test script for the new Vampire Voice (deep_ah) with divine reverb effects
"""

import sys
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from services.tts_service import generate_audio_for_text, get_available_voices


def test_vampire_voice():
    """Test the vampire voice with various gothic phrases"""
    print("🧛‍♂️ Testing Vampire Voice (deep_ah) with Divine Reverb Effects")
    print("=" * 60)
    
    # Test phrases perfect for a vampire voice
    test_phrases = [
        "It is the 41st Millennium. For more than a hundred centuries the Emperor has sat immobile on the Golden Throne of Earth. He is the master of mankind by the will of the gods, and master of a million worlds by the might of his inexhaustible armies. He is a rotting carcass writhing invisibly with power from the Dark Age of Technology. He is the Carrion Lord of the Imperium for whom a thousand souls are sacrificed every day, so that he may never truly die. Yet even in his deathless state, the Emperor continues his eternal vigilance. Mighty battlefleets cross the daemon-infested miasma of the warp, the only route between distant stars, their way lit by the Astronomican, the psychic manifestation of the Emperor's will. Vast armies give battle in his name on uncounted worlds. Greatest amongst his soldiers are the Adeptus Astartes, the Space Marines, bio-engineered super-warriors. Their comrades in arms are legion: the Imperial Guard and countless planetary defense forces, the ever-vigilant Inquisition, and the tech-priests of the Adeptus Mechanicus to name only a few. But for all their multitudes, they are barely enough to hold off the ever-present threat from aliens, heretics, mutants—and worse. To be a man in such times is to be one amongst untold billions. It is to live in the cruellest and most bloody regime imaginable. These are the tales of those times. Forget the power of technology and science, for so much has been forgotten, never to be relearned. Forget the promise of progress and understanding, for in the grim darkness of the far future, there is only war. There is no peace amongst the stars, only an eternity of carnage and slaughter, and the laughter of thirsting gods.",
        "Your mortal concerns are but whispers in the eternal night... The shell has spoken.",
        "The depths of eternity reveal neither solace nor answers... The shell has spoken.",
        "From the shadows of time immemorial, wisdom flows like blood through stone... The shell has spoken.",
        "Yes",
        "No", 
        "The path you seek is shrouded in mist and moonlight... The shell has spoken."
    ]
    
    print("Available voices:")
    voices = get_available_voices()
    if "deep_ah" in voices:
        print(f"✅ deep_ah: {voices['deep_ah']}")
    else:
        print("❌ deep_ah voice not found!")
        return
    
    print(f"\nGenerating vampire voice samples with divine reverb effects...")
    print("-" * 60)
    
    for i, phrase in enumerate(test_phrases, 1):
        try:
            print(f"🎤 Test {i}: '{phrase[:50]}{'...' if len(phrase) > 50 else ''}'")
            result = generate_audio_for_text(phrase, "deep_ah")
            print(f"   ✅ Generated: {result}")
            print(f"   🏛️  Expected divine reverb effect applied for godly atmosphere")
        except Exception as e:
            print(f"   ❌ Error: {e}")
        print()
    
    print("🎭 Vampire voice testing complete!")
    print("\nTips:")
    print("- The vampire voice should have a deep, eastern European accent")
    print("- Divine reverb effects should add ethereal, heavenly atmosphere")
    print("- Perfect for mystical conch responses")
    print("- Files with '_godly_reverb' suffix have enhanced cathedral-like effects")


def test_voice_comparison():
    """Compare the vampire voice with other voices"""
    print("\n🔀 Voice Comparison Test")
    print("=" * 60)
    
    test_text = "The shell has spoken with ancient wisdom."
    comparison_voices = ["rachel", "fin", "thomas", "deep_ah"]
    
    for voice in comparison_voices:
        try:
            print(f"Testing {voice}...")
            result = generate_audio_for_text(test_text, voice)
            print(f"✅ {voice}: {result}")
        except Exception as e:
            print(f"❌ {voice}: Error - {e}")


if __name__ == "__main__":
    test_vampire_voice()
    test_voice_comparison()
    
    print("\n" + "="*60)
    print("🚀 Ready to use the Vampire Voice in your API!")
    print("The 'deep_ah' voice is now the default for mystical responses.")
    print("Start your server: uvicorn main:app --reload")
