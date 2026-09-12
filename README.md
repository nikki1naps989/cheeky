# Cheek Club — website

Static site. No build step, no dependencies. Open `index.html` in a browser, or drop
the whole folder on any host (Netlify, Vercel, GitHub Pages, Squarespace file upload).

| File | What it is |
| --- | --- |
| `index.html` | Homepage. Both "Join the Founding 100" and "Get on the list" point at `founding100.html`. |
| `founding100.html` | The Founding 100 signup page — captures real signups and shows spots remaining. |
| `styles.css` | Shared stylesheet for both pages (brand palette, type, layout). |
| `docs/funding.md` | Funding structure and the $200,000 investor ask. |

---

## Making the signup page live — two edits

Both live at the top of the `<script>` block near the **bottom** of `founding100.html`,
labelled `EDIT 1 of 2` and `EDIT 2 of 2`. Nothing else needs touching.

### Edit 1 — Formspree (this is the one that matters)

Captures real signups and emails them to you.

1. Go to [formspree.io](https://formspree.io) → sign up free → **New Form**
2. Copy the form ID out of the endpoint it gives you — it looks like `xandpqrs`
3. Paste it here:

```js
var FORMSPREE_ID = "xandpqrs";
```

Free tier is 50 submissions/month. Half the Founding 100 in your first month would
exceed it, so watch the count and upgrade if it starts filling fast.

### Edit 2 — CounterAPI (the live "spots remaining" number)

**Optional.** See the honest note below before deciding.

1. Go to [counterapi.dev](https://counterapi.dev) → sign up free → create a workspace
2. Generate an API key from the dashboard
3. Paste both here:

```js
var COUNTER_WORKSPACE = "cheekclub";
var COUNTER_API_KEY   = "your-key-here";
```

---

## If you'd rather skip CounterAPI entirely

Leave `COUNTER_WORKSPACE` and `COUNTER_API_KEY` exactly as they are. The page then
runs the counter off this number instead, and you bump it by hand as signups land
in your inbox:

```js
var SPOTS_CLAIMED_MANUAL = 12;   // 12 claimed -> page shows "88"
```

This is the zero-third-party version. The page looks identical to a visitor — the
only difference is that you update one number yourself instead of it updating itself.

You can switch between the two at any time; filling in the CounterAPI values takes
over, removing them hands it back to the manual number.

---

## Honest limitations

**The API key is visible in the page source.** Anyone who opens developer tools can
read it and, in theory, push the counter up or down. For a studio's signup count the
real-world risk is low — there's nothing to steal and nothing to break but a number
on a marketing page — but it is not bank-grade security, and it's the reason the
manual fallback above exists. Never reuse that key for anything that matters.

**The counter is a display, not the record.** Formspree holds the actual signups.
If the counter drifts, the email list is the truth — reconcile against it, not the
other way round.

**The page degrades rather than breaking.** These were tested in a browser:

| If this happens | The page does this |
| --- | --- |
| CounterAPI is down or misconfigured | Falls back to `SPOTS_CLAIMED_MANUAL`, no error shown |
| Formspree returns an error | Keeps the form filled in, re-enables the button, shows a message with your email as a fallback |
| Formspree ID not filled in yet | Says so plainly instead of silently discarding a signup |
| All 100 spots claimed | Shows "Full", disables the button, points at the general waitlist |
| Viewed on a phone | Single column, no horizontal scroll |

**Placeholder contact details.** `hello@cheekclub.com`, `(702) 555-0100` and the
Instagram link are placeholders — swap them for real ones before launch.
`docs/funding.md` lists the rest.
