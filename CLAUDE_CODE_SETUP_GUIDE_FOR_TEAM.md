# CLAUDE CODE SETUP GUIDE FOR TEAM MEMBERS
## How to Create and Use a GitHub Repository with Claude Code

---

## STEP 1: CREATE A GITHUB REPOSITORY

### 1.1 Go to GitHub
- Visit: https://github.com
- Sign in with your GitHub account (create one if needed)

### 1.2 Create New Repository
- Click the **"+"** icon in top-right corner
- Select **"New repository"**
- Fill in these details:

```
Repository Name:     my-sql-assignment
Description:         SQL Portfolio Analysis for UHNW Client
Visibility:          Public (or Private if preferred)
Initialize with:     ☑ Add a README file
                     ☑ Add .gitignore (choose Python)
                     ☑ Choose a license (MIT is fine)
```

- Click **"Create repository"**

### 1.3 Copy Repository URL
- Click the green **"<> Code"** button
- Copy the HTTPS URL (looks like: `https://github.com/username/my-sql-assignment.git`)
- Save it somewhere (you'll need it)

---

## STEP 2: OPEN CLAUDE CODE

### 2.1 Start Claude Code
Choose ONE of these options:

**Option A: Web Version** (Easiest for First-Time)
- Go to: https://claude.ai/code
- Sign in with your Claude account

**Option B: Desktop App**
- Download from: https://claude.com/download
- Install and open Claude Code

**Option C: IDE Extension**
- Install Claude Code extension in:
  - VS Code
  - JetBrains IDEs (IntelliJ, PyCharm, etc.)

### 2.2 Create New Project
- Click **"New Project"** button
- Select **"Clone a Repository"**
- Paste your GitHub repository URL from Step 1.3
- Click **"Clone"**

---

## STEP 3: WAIT FOR CLAUDE CODE SETUP

Claude Code will automatically:
- Clone the repository to your local machine
- Open a connection to the repository
- Set up the working directory

You should see:
```
Project initialized
Repository: my-sql-assignment
Branch: main (default)
Ready to work
```

---

## STEP 4: START WORKING WITH FILES

### 4.1 Create a New File
- Right-click in the file explorer
- Select **"New File"**
- Name it (e.g., `Q1_INDIVIDUAL_RETURNS.sql`)
- Write your SQL code

### 4.2 Edit Existing Files
- Click on any file in the explorer
- Make changes in the editor
- Changes are shown in real-time

### 4.3 See File Status
```
Files with changes appear with:
  M = Modified (changed)
  ? = Untracked (new file)
  D = Deleted
```

---

## STEP 5: COMMIT AND PUSH CHANGES

### 5.1 Check What Changed
```bash
git status
```
This shows all modified/new files

### 5.2 Prepare Changes to Send
Claude Code can do this, or use terminal:

```bash
# Add all files
git add .

# Or add specific file
git add Q1_INDIVIDUAL_RETURNS.sql
```

### 5.3 Create a Commit (Save Point)
```bash
git commit -m "Add Q1 SQL query for individual returns analysis"
```

Example good commit messages:
- "Add Q1_INDIVIDUAL_RETURNS.sql with 12M analysis"
- "Update assignment conclusion with Sharpe ratio justification"
- "Add portfolio analysis document"

**AVOID:**
- "update" (too vague)
- "fix" (too vague)
- "asdf" (meaningless)

### 5.4 Push to GitHub (Send to Server)
```bash
git push -u origin main
```

Or if you're on a different branch:
```bash
git push -u origin branch-name
```

---

## STEP 6: VERIFY ON GITHUB

### 6.1 Check GitHub Website
- Go to: https://github.com/username/my-sql-assignment
- You should see your files and commits

### 6.2 See Commit History
- Click **"Code"** tab
- Scroll down to see all commits
- Click on commit to see what changed

---

## COMMON WORKFLOW CYCLE

```
1. Start Claude Code
   ↓
2. Create/Edit files
   ↓
3. Check changes (git status)
   ↓
4. Stage changes (git add)
   ↓
5. Commit with message (git commit -m "...")
   ↓
6. Push to GitHub (git push)
   ↓
7. Verify on GitHub website
   ↓
8. Done! Your files are now backed up and shareable
```

---

## USEFUL CLAUDE CODE COMMANDS

### Terminal Commands in Claude Code
Claude Code has a terminal tab where you can run:

```bash
# See git status
git status

# See commit history
git log --oneline -10

# Create new branch
git checkout -b my-new-branch

# Switch branches
git checkout main

# Pull latest changes
git pull origin main

# View file differences
git diff filename.sql
```

---

## TROUBLESHOOTING

### Problem: "Authentication Failed"
**Solution:**
- Use GitHub personal access token instead of password
- Go to: https://github.com/settings/tokens
- Generate new token with "repo" scope
- Use token as password

### Problem: "Branch is up to date"
**Solution:** This is normal - means your local files match GitHub. No action needed.

### Problem: "Merge conflict"
**Solution:** Ask your team lead or contact Claude Code support. This happens when two people edit same file.

### Problem: "Permission denied"
**Solution:**
- Make sure repository is set to Public
- Or add yourself as a collaborator in repository settings

---

## STEP-BY-STEP EXAMPLE SESSION

### Session 1: Initial Setup
```
1. Create GitHub repo → "my-sql-assignment"
2. Copy repository URL
3. Open Claude Code → "Clone Repository"
4. Paste URL and clone
5. Wait for setup complete
```

### Session 2: Add First Files
```
1. Create file: Q1_INDIVIDUAL_RETURNS.sql
2. Write SQL code inside
3. Terminal: git add Q1_INDIVIDUAL_RETURNS.sql
4. Terminal: git commit -m "Add Q1 SQL query"
5. Terminal: git push -u origin main
6. Check GitHub.com - file should appear
```

### Session 3: Continue Working
```
1. Reopen Claude Code (same project)
2. Edit existing files or create new ones
3. Terminal: git add .
4. Terminal: git commit -m "Update Q1 query and add Q2 query"
5. Terminal: git push
6. Done!
```

---

## KEY POINTS FOR TEAM MEMBERS

✅ **DO:**
- Create meaningful commit messages
- Commit frequently (small changes, not everything at once)
- Push changes daily (backup your work)
- Use descriptive file names
- Test your SQL before committing

❌ **DON'T:**
- Commit large binary files (images, videos, zip files)
- Commit .env or credentials files
- Make huge commits (100+ file changes at once)
- Push without testing first
- Delete other people's files

---

## GETTING HELP

### Claude Code Documentation
- Official guide: https://claude.com/docs
- FAQ: https://support.anthropic.com

### Git/GitHub Help
- Git basics: https://git-scm.com/book/en/v2
- GitHub guide: https://docs.github.com

### In Claude Code
- Type `/help` in the chat
- Read system messages for hints
- Ask Claude directly for help

---

## SECURITY REMINDER

Never commit these files to GitHub:
- `.env` (environment variables)
- `credentials.json` (API keys)
- `password.txt` (passwords)
- `secrets.yaml` (private keys)

Use `.gitignore` file to exclude them:
```
.env
credentials.json
*.key
*.pem
```

---

## NEXT STEPS FOR YOUR TEAM

1. Each team member creates their own GitHub account
2. One person creates the main repository
3. Add team members as collaborators:
   - GitHub repo → Settings → Collaborators → Add people
4. Each person clones the repository to their local machine
5. Start working and pushing changes
6. Pull latest changes before starting work: `git pull origin main`

---

## QUICK REFERENCE CARD

```
FIRST TIME SETUP:
  1. Create GitHub repo
  2. Copy HTTPS URL
  3. Claude Code → Clone Repository
  4. Paste URL and wait for setup

DAILY WORKFLOW:
  git status                    (see what changed)
  git add .                     (prepare files)
  git commit -m "message"       (save changes locally)
  git push                      (send to GitHub)

TEAM SYNC:
  git pull origin main          (get latest from team)
  [make your changes]
  git add .
  git commit -m "your work"
  git push                      (share with team)
```

---

## SUPPORT

If your team member gets stuck:
1. Check this guide again
2. Read Claude Code `/help` command
3. Search GitHub issues: https://github.com/anthropics/claude-code/issues
4. Contact your tech lead or project manager

Good luck! 🚀
