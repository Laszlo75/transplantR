# PII Protection System

This repository includes an automated system to prevent accidental commits of Patient Identifiable Information (PII).

## 🛡️ Protection Layers

### 1. Pre-commit Hook (Local)
Runs automatically before every commit to scan staged files for PII patterns.

**Location:** `.git/hooks/pre-commit`

**What it detects:**
- ✅ NHS numbers (format: XXX XXX XXXX or XXXXXXXXXX)
- ✅ UK phone numbers
- ✅ UK postcodes
- ✅ Date patterns (potential DOB or admission dates)
- ✅ Email addresses (except whitelisted)
- ✅ Medical record numbers (MRN, Patient ID, etc.)
- ✅ Names with titles (Mr, Mrs, Dr, etc.)

**How it works:**
1. You run `git commit`
2. Hook automatically scans staged files
3. If high-confidence PII found → **commit blocked**
4. If low-confidence patterns found → **warning + confirmation prompt**
5. If clean → **commit proceeds**

### 2. GitHub Actions (Remote Backup)
Runs on every push and pull request as a safety net.

**Location:** `.github/workflows/pii-check.yaml`

**Benefits:**
- Catches anything that bypassed local hook
- Scans entire repository history
- Prevents merging PRs with PII
- Public visibility of security checks

## 📝 Whitelist Configuration

**File:** `.pii-whitelist`

Add safe patterns that should be excluded from PII detection:

```bash
# Your safe patterns
your-email@example.com
example date pattern
test data values
```

**When to add to whitelist:**
- ✅ Your professional contact information
- ✅ Generic example values in documentation
- ✅ Test data that's clearly synthetic
- ✅ Years used in version numbers or dates ranges
- ❌ Never whitelist actual patient data

## 🚨 What to Do When Hook Triggers

### If you see: "✗ COMMIT BLOCKED"

This means **high-confidence PII** was detected. You should:

1. **Review the flagged content** - Check the lines shown in the output
2. **Remove the PII** - Delete or anonymize the actual patient data
3. **Try again** - Stage and commit the cleaned files

```bash
# After removing PII
git add <fixed-file>
git commit -m "your message"
```

### If you see: "⚠ WARNING"

This means **possible PII** was detected (could be false positive). You should:

1. **Carefully review** - Check if it's actual PII or just documentation
2. **Choose:**
   - Type `n` to cancel and review further
   - Type `y` to proceed if it's a false positive
3. **If false positive** - Add the pattern to `.pii-whitelist`

```bash
# Add safe pattern to whitelist
echo "your safe pattern" >> .pii-whitelist
git add .pii-whitelist
git commit -m "Update PII whitelist"
```

## ⚙️ Bypassing the Hook (Emergency Only)

**⚠️ NOT RECOMMENDED** - Only use in genuine emergencies:

```bash
git commit --no-verify
```

**Never bypass if:**
- You haven't reviewed the flagged content
- There's actual PII in your files
- You're unsure what triggered the warning

## 🔧 Maintenance

### Update Detection Patterns

Edit the pre-commit hook: `.git/hooks/pre-commit`

Add new regex patterns to scan for additional PII types.

### Test the Hook

```bash
# Create a test file with fake PII
echo "NHS: 123 456 7890" > test.txt
git add test.txt
git commit -m "test"
# Should be blocked!

# Clean up
rm test.txt
git reset HEAD test.txt
```

### Disable Temporarily (Not Recommended)

```bash
# Rename the hook to disable it
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# Re-enable
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

## 📊 Monitoring

Check PII scan results in GitHub Actions:
- Go to: https://github.com/Laszlo75/transplantR/actions
- Click on any workflow run
- Review the "PII Check" job results

## 🎯 Best Practices

1. **Never commit PDFs or Excel files** with patient data
   - PDFs/Excel are blocked by default
   - Store sensitive files outside the repository

2. **Use synthetic data for examples**
   - Create fictional test cases
   - Use obviously fake values (e.g., DOB: 1900-01-01)

3. **Keep whitelist minimal**
   - Only add genuinely safe patterns
   - Document why each pattern is safe

4. **Review warnings seriously**
   - Don't habitually press 'y' on warnings
   - Investigate each flagged item

5. **Regular audits**
   - Periodically review repository with fresh eyes
   - Check git history for old commits with PII

## 📞 Questions or Issues?

If the PII detection system is:
- Blocking legitimate code → Update `.pii-whitelist`
- Missing actual PII → Update patterns in `.git/hooks/pre-commit`
- Causing problems → Contact the package maintainer

## 🔒 GDPR Compliance

This system helps maintain GDPR compliance by:
- Preventing PII commits (Art. 32 - Security of processing)
- Providing audit trail (GitHub Actions logs)
- Enforcing data protection by design
- Supporting UK Data Protection Act 2018 requirements

**Remember:** This is a technical safeguard, not a replacement for proper data governance and training.
