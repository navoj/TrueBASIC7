#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path

def test_file(filepath, debug=False):
    """Try to compile a BASIC file"""
    try:
        cmd = ['raku', 'TrueBASICDecimal.raku']
        if debug:
            cmd.append('--debug')
        cmd.append(str(filepath))
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        output = result.stdout + result.stderr
        
        # Check for success indicators
        if 'Compilation successful' in output:
            return 'PASS', output
        elif 'Compilation failed' in output:
            return 'FAIL', output
        else:
            return 'UNKNOWN', output
    except subprocess.TimeoutExpired:
        return 'TIMEOUT', 'Execution timed out'
    except Exception as e:
        return 'ERROR', str(e)

def main():
    # Find all .TRU and .tru files
    examples_dir = Path('examples')
    example_files = sorted(examples_dir.glob('*.TRU')) + sorted(examples_dir.glob('*.tru'))
    
    print(f"Testing {len(example_files)} BASIC example programs...\n")
    
    results = {'PASS': [], 'FAIL': [], 'TIMEOUT': [], 'ERROR': [], 'UNKNOWN': []}
    
    for filepath in example_files[:10]:  # Test first 10
        filename = filepath.name
        sys.stdout.write(f"{filename:<35} ")
        sys.stdout.flush()
        
        status, output = test_file(filepath, debug=False)
        results[status].append(filename)
        
        if status == 'PASS':
            print("✓")
        elif status == 'FAIL':
            print("✗")
        elif status == 'TIMEOUT':
            print("⏱")
        elif status == 'ERROR':
            print("E")
        else:
            print("?")
    
    print("\n" + "=" * 70)
    print("TEST SUMMARY")
    print("=" * 70)
    print(f"Passed:   {len(results['PASS'])}")
    print(f"Failed:   {len(results['FAIL'])}")
    print(f"Timeout:  {len(results['TIMEOUT'])}")
    print(f"Error:    {len(results['ERROR'])}")
    print(f"Unknown:  {len(results['UNKNOWN'])}")
    print(f"Total:    {len(example_files)}")
    
    if results['PASS']:
        print("\n✓ Successful compilations:")
        for f in results['PASS'][:10]:
            print(f"  • {f}")
    
    if results['FAIL']:
        print("\n✗ Failed compilations:")
        for f in results['FAIL'][:10]:
            print(f"  • {f}")

if __name__ == '__main__':
    main()
