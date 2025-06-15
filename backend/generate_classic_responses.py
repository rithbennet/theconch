#!/usr/bin/env python3
"""
Generate Classic Conch Responses with Deep_Ah Voice
Creates unique versions of the classic responses: Yes, No, Maybe, and Definitely not
Each response will have a unique mystical variation based on the deep_ah vampire voice
"""

import os
import sys
from pathlib import Path

# Add the backend directory to the Python path
backend_dir = Path(__file__).parent
sys.path.insert(0, str(backend_dir))

from services.tts_service import generate_audio_for_text, get_available_voices, is_voice_available


def create_classic_responses():
    """Generate the four classic conch responses with unique mystical variations"""
    
    print("🧛‍♂️ Generating Classic Conch Responses with Deep_Ah Vampire Voice")
    print("=" * 70)
    
    # Check if deep_ah voice is available
    if not is_voice_available("deep_ah"):
        print("❌ Error: deep_ah voice is not available!")
        print("Available voices:", list(get_available_voices().keys()))
        return False
    
    print("✅ Deep_ah voice is available!")
    print("🎭 Voice: Deep Ah - Nosferatu Ancient Vampire Lord (Matthew Schmitz)")
    print()
    
    # Define unique mystical variations for each classic response (short for <5 seconds)
    responses = {
        "yes": {
            "text": "Yessss... it is certain.",
            "filename": "yes.mp3",
            "description": "Short mystical affirmative response"
        },
        "no": {
            "text": "Noooo... forbidden.",
            "filename": "No.mp3", 
            "description": "Short dark rejection"
        },
        "maybe": {
            "text": "Perhaps... unclear.",
            "filename": "Maybe.mp3",
            "description": "Short mystical uncertainty"
        },
        "definitely_not": {
            "text": "Never... foolish mortal.",
            "filename": "Definietly_not.mp3",  # Keep original filename spelling
            "description": "Short strong rejection"
        }
    }
    
    # Create output directory for new responses
    output_dir = Path("audio/classic/deep_ah_responses")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"📁 Output directory: {output_dir}")
    print()
    
    # Generate each response
    success_count = 0
    total_count = len(responses)
    
    for response_key, response_data in responses.items():
        print(f"🎤 Generating '{response_key}'...")
        print(f"   Text: \"{response_data['text']}\"")
        print(f"   File: {response_data['filename']}")
        print(f"   Description: {response_data['description']}")
        
        try:
            # Generate the audio using the TTS service
            audio_path = generate_audio_for_text(response_data['text'], "deep_ah")
            
            # The audio_path will be in the format: /audio/generated/filename_deep_ah.mp3
            # We need to copy/move it to our desired location with the correct filename
            
            print(f"   ✅ Generated: {audio_path}")
            print(f"   🏛️  Divine reverb effect applied for godly atmosphere")
            success_count += 1
            
        except Exception as e:
            print(f"   ❌ Error generating {response_key}: {e}")
        
        print()
    
    # Summary
    print("=" * 70)
    print(f"🎉 Classic Response Generation Complete!")
    print(f"📊 Success Rate: {success_count}/{total_count} responses generated")
    
    if success_count == total_count:
        print("✅ All responses generated successfully!")
        print()
        print("🔄 To replace the british_lady voice:")
        print("1. The generated files are in audio/generated/ with deep_ah suffix")
        print("2. Copy them to audio/classic/british_lady/ with the correct names:")
        print("   - Copy the 'yes' response as 'yes.mp3'")
        print("   - Copy the 'no' response as 'No.mp3'") 
        print("   - Copy the 'maybe' response as 'Maybe.mp3'")
        print("   - Copy the 'definitely_not' response as 'Definietly_not.mp3'")
        print()
        print("🎭 Each response now has unique mystical vampire characteristics!")
        print("🧛‍♂️ Deep, eastern European accent with divine reverb effects")
        print("🏛️  Cathedral-like atmosphere for otherworldly wisdom")
        
    else:
        print("⚠️  Some responses failed to generate. Check the errors above.")
    
    return success_count == total_count


def copy_responses_to_british_lady_folder():
    """Copy the generated responses to replace the british_lady files"""
    
    print("\n🔄 Copying Generated Responses to British Lady Folder...")
    print("=" * 60)
    
    import shutil
    import glob
    
    # Source directory (generated files)
    generated_dir = Path("audio/generated")
    
    # Target directory (british_lady folder)
    british_lady_dir = Path("audio/classic/british_lady")
    
    # Make sure british_lady directory exists
    british_lady_dir.mkdir(parents=True, exist_ok=True)
    
    # Mapping of generated files to target names
    # We'll look for files containing these keywords
    file_mappings = {
        "yessss": "yes.mp3",
        "noooo": "No.mp3",  # "Noooo..." becomes "No.mp3"
        "perhaps": "Maybe.mp3",  # "Perhaps..." becomes "Maybe.mp3" 
        "never": "Definietly_not.mp3"  # "Never..." becomes "Definietly_not.mp3"
    }
    
    copied_count = 0
    
    for search_term, target_filename in file_mappings.items():
        try:
            # Find the generated file containing the search term
            pattern = f"*{search_term}*_deep_ah*.mp3"
            matches = list(generated_dir.glob(pattern))
            
            if not matches:
                # Try alternative patterns
                if search_term == "yessss":
                    matches = list(generated_dir.glob("*yessss*_deep_ah*.mp3"))
                elif search_term == "noooo":
                    matches = list(generated_dir.glob("*noooo*_deep_ah*.mp3"))
                elif search_term == "perhaps":
                    matches = list(generated_dir.glob("*perhaps*_deep_ah*.mp3"))
                elif search_term == "never":
                    matches = list(generated_dir.glob("*never*_deep_ah*.mp3"))
            
            if matches:
                source_file = matches[0]  # Take the first match
                target_file = british_lady_dir / target_filename
                
                # Copy the file
                shutil.copy2(source_file, target_file)
                print(f"✅ Copied: {source_file.name} → {target_filename}")
                copied_count += 1
                
            else:
                print(f"❌ No generated file found for '{search_term}' pattern: {pattern}")
                
        except Exception as e:
            print(f"❌ Error copying {search_term}: {e}")
    
    print(f"\n📊 Copied {copied_count}/{len(file_mappings)} files successfully")
    
    if copied_count == len(file_mappings):
        print("🎉 All classic responses have been replaced with deep_ah vampire voice!")
        print("🧛‍♂️ The british_lady voice folder now contains mystical vampire responses")
        print("🏛️  Each response has divine reverb for otherworldly atmosphere")
    else:
        print("⚠️  Some files could not be copied. You may need to copy them manually.")
        print("\n📁 Check these directories:")
        print(f"   Source: {generated_dir}")
        print(f"   Target: {british_lady_dir}")
    
    return copied_count == len(file_mappings)


def main():
    """Main function to generate and replace classic responses"""
    
    print("🐚 The Conch Voice Replacement Tool")
    print("Replacing british_lady with unique deep_ah vampire variations")
    print()
    
    # Step 1: Generate the responses
    generation_success = create_classic_responses()
    
    if generation_success:
        # Step 2: Copy them to the british_lady folder
        copy_success = copy_responses_to_british_lady_folder()
        
        if copy_success:
            print("\n🎭 Voice Replacement Complete!")
            print("🧛‍♂️ The Conch now speaks with the voice of an ancient vampire lord")
            print("🏛️  Divine reverb effects add otherworldly, godly atmosphere")
            print("\n🚀 Ready to test:")
            print("   python test_tts.py")
            print("   python test_vampire_voice.py")
            print("   uvicorn main:app --reload")
        else:
            print("\n⚠️  Manual copying required - see instructions above")
    else:
        print("\n❌ Generation failed - check your ElevenLabs API key and connection")


if __name__ == "__main__":
    main()
