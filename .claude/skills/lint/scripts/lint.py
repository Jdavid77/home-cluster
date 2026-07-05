#!/usr/bin/env python3
import sys
from checks.schema_comments import check_schema_comments
from checks.ks_order import check_ks_yaml_order
from checks.hr_order import check_helm_release_order

if __name__ == "__main__":
    all_passed = True

    schema_issues = check_schema_comments()
    if schema_issues:
        all_passed = False
        print(f"[Check 1] Missing yaml-language-server schema comment — {len(schema_issues)} file(s):")
        for f in schema_issues:
            print(f"  {f}")

    order_issues = check_ks_yaml_order()
    if order_issues:
        all_passed = False
        print(f"[Check 2] ks.yaml spec property order — {len(order_issues)} file(s):")
        for filepath, actual, expected in order_issues:
            print(f"  {filepath}")
            print(f"    found:    {', '.join(actual)}")
            print(f"    expected: {', '.join(expected)}")

    hr_order_issues = check_helm_release_order()
    if hr_order_issues:
        all_passed = False
        print(f"[Check 3] helm-release.yaml values order — {len(hr_order_issues)} violation(s):")
        for filepath, section, actual, expected in hr_order_issues:
            print(f"  {filepath} [{section}]")
            print(f"    found:    {', '.join(actual)}")
            print(f"    expected: {', '.join(expected)}")

    if all_passed:
        print("All checks passed.")
        sys.exit(0)
    else:
        sys.exit(1)
