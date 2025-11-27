# Set OpenAI API Key Secret - Correct Way

## ❌ What Went Wrong

You tried to use the API key itself as the secret name. The secret name should be `OPENAI_API_KEY`, and the API key is the **value**.

## ✅ Correct Way

### Step 1: Run the command with the secret NAME

```bash
firebase functions:secrets:set OPENAI_API_KEY
```

**Note**: `OPENAI_API_KEY` is the **name** of the secret, not the value.

### Step 2: When prompted, enter your API key

When you see:
```
✔ Enter a value for OPENAI_API_KEY:
```

**Paste your OpenAI API key** (the long string starting with `sk-`)

**Do NOT press Enter immediately** - wait for the prompt, then paste the key.

---

## 🔍 **What Happened**

You ran:
```bash
firebase functions:secrets:set sk-proj--6m2d6jtRii7UhJbTPaoMWBB1EDWOvxR74...
```

This tried to use your API key as the secret name, which is wrong.

---

## ✅ **Correct Command**

```bash
firebase functions:secrets:set OPENAI_API_KEY
```

Then when prompted, paste your API key.

---

## 🔒 **Security Note**

- The secret name is `OPENAI_API_KEY` (always uppercase with underscores)
- The secret value is your actual API key (starts with `sk-`)
- Firebase will securely store it and make it available to functions

---

*Run the command with OPENAI_API_KEY as the name, then paste your key when prompted!*






