import os
import re

def refactor_opacity(directory):
    pattern = re.compile(r'\.withOpacity\((.*?)\)')
    replacement = r'.withValues(alpha: \1)'
    
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = pattern.sub(replacement, content)
                
                if new_content != content:
                    print(f"Refactoring {file_path}...")
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)

if __name__ == "__main__":
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    lib_dir = os.path.join(project_root, 'lib')
    refactor_opacity(lib_dir)
    print("Refactoring complete!")
