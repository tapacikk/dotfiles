#!/usr/bin/env python3
import argparse
import re

# Conversion constants
HARTREE_TO_EV = 27.211386245988
HARTREE_TO_CM = 219474.6313705
HARTREE_TO_KJ = 2625.499638
HARTREE_TO_KCAL = HARTREE_TO_KJ / 4.184
EV_TO_NM = 1239.841984

def parse_arguments():
    parser = argparse.ArgumentParser(prog='e',
                                     description='Simple Energy Converter')
    parser.add_argument('value', type=str, help='Energy value and units (e.g. "2 h", "100cm", "7kJ/mol")')
    parser.add_argument('units', nargs='?', help='Units (optional if given in value)')
    return parser.parse_args()

def parse_value_and_unit(value_str, unit_arg):
    """Extract numeric value and unit from inputs like '10cm' or '2.5 eV'."""
    if unit_arg:  # Space-separated case
        return float(value_str), unit_arg
    # Match number + unit (allow decimals, scientific notation, slashes)
    match = re.match(r'^([0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)\s*([a-zA-Z/]+)$', value_str)
    if not match:
        raise ValueError(f"Could not parse value and units from '{value_str}'")
    return float(match.group(1)), match.group(2)

def to_hartree(value, units):
    if units == 'h':
        return value
    elif units == 'ev' or units == 'eV':
        return value / HARTREE_TO_EV
    elif units == 'cm':
        return value / HARTREE_TO_CM
    elif units == 'kJ/mol':
        return value / HARTREE_TO_KJ
    elif units == 'kcal/mol':
        return value / HARTREE_TO_KCAL
    elif units == 'nm':
        ev = EV_TO_NM / value
        return ev / HARTREE_TO_EV
    else:
        raise ValueError(f"Unsupported units: {units}")

def from_hartree(h):
    ev = h * HARTREE_TO_EV
    cm = h * HARTREE_TO_CM
    kj = h * HARTREE_TO_KJ
    kcal = h * HARTREE_TO_KCAL
    nm = EV_TO_NM / ev if ev != 0 else float('inf')
    return {
        'Harthree': h,
        'eV': ev,
        'cm-1': cm,
        'kJ/mol': kj,
        'kcal/mol': kcal,
        'nm': nm
    }

def main():
    args = parse_arguments()
    value, units = parse_value_and_unit(args.value, args.units)
    hartree = to_hartree(value, units)
    results = from_hartree(hartree)

    for unit, val in results.items():
        print(f"{unit:10}: {val:.12g}")

if __name__ == '__main__':
    main()
