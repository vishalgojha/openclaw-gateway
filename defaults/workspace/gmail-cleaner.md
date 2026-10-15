# Gmail Junk Cleaner Skill

Purpose: Clean Gmail junk safely using IMAP app password. Interactive, dry-run first.

## Commands the user might say
- "Clean my Gmail"
- "Delete old Gmail emails"
- "Empty Gmail spam/trash"
- "Find emails larger than 10MB"
- "Clean promotions"

## Workflow
1. Check if we have credentials. If not, ask for:
   - Gmail address
   - Gmail App Password (16 chars). Explain: need 2FA enabled, generate at myaccount.google.com/apppasswords -> Other
2. Confirm settings: older_than=1y, larger_than=10MB, categories=promotions/updates/social/forums, protect_starred=true, delete_spam/trash? ask
3. Run dry-run first. Show breakdown: Spam, Trash, Older than 1y, Larger than 10MB, each category. Show counts.
4. Ask: "Do you want to actually delete these? Reply yes to proceed." Only then run with DRY_RUN=false.
5. Report results after.

## Safety
- Never touch Sent, Chats, Drafts
- Never delete starred
- Batch operations, show what will be affected
- Never ask for regular Gmail password
- Never share credentials in responses
