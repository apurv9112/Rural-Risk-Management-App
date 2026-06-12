import os
import re

test_dir = 'test'

def process_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    changed = False
    for i in range(len(lines)):
        if r'\1' in lines[i]:
            # It's a syntax error like mediaRepo.insert(\1);
            # Just replace \1 with a dummy so it compiles. 
            # Or better, we can replace it with mediaQueue or syncQueue based on the repo.
            if 'syncRepo' in lines[i]:
                lines[i] = lines[i].replace(r'\1', 'syncQueue')
                changed = True
            elif 'mediaRepo' in lines[i]:
                lines[i] = lines[i].replace(r'\1', 'mediaQueue')
                changed = True
                
            # If it's a getById, it expects a String.
            if 'getById(' in lines[i] or 'getBySyncQueueId(' in lines[i]:
                lines[i] = lines[i].replace('syncQueue', "'sync_1'")
                lines[i] = lines[i].replace('mediaQueue', "'media_1'")
                
    if changed:
        with open(path, 'w', encoding='utf-8') as f:
            f.writelines(lines)
            print(f"Fixed {path}")

for root, _, files in os.walk(test_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
