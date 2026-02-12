# jeyjos Setup Checklist

Use this checklist to complete the setup of your jeyjos operating system.

## ✅ Completed (by Bootstrap)

- [x] Repository created from finpilot template
- [x] All "finpilot" references renamed to "jeyjos"
- [x] GitHub Actions workflows configured and validated
- [x] README enhanced with comprehensive setup instructions
- [x] "What Makes jeyjos Different?" section added
- [x] Build scripts validated with shellcheck
- [x] YAML workflows validated
- [x] Code quality checks passed

## 📋 Next Steps (Your Action Required)

### 1. Merge This PR ⚡ REQUIRED

- [ ] Review the changes in this pull request
- [ ] Merge the PR to main branch
- [ ] This will trigger the first build automatically

### 2. Verify GitHub Actions Permissions ⚡ REQUIRED

- [ ] Go to: https://github.com/jeyj0/jeyjos/settings/actions
- [ ] Under "Workflow permissions":
  - [ ] Select "Read and write permissions"
  - [ ] Check "Allow GitHub Actions to create and approve pull requests"
- [ ] Click "Save"

### 3. Monitor First Build ⚡ REQUIRED

- [ ] Go to: https://github.com/jeyj0/jeyjos/actions
- [ ] Watch the "Build container image" workflow
- [ ] Wait for green checkmark (5-15 minutes)
- [ ] Verify no errors in build logs

### 4. Make Package Public ⚡ REQUIRED

After first build completes:

- [ ] Go to: https://github.com/jeyj0?tab=packages
- [ ] Find the "jeyjos" package
- [ ] Click on package → Package settings
- [ ] Change visibility → "Public"
- [ ] Confirm the change

### 5. Verify Image is Accessible ⚡ REQUIRED

Test pulling the image:

```bash
podman pull ghcr.io/jeyj0/jeyjos:stable
```

Expected: Image downloads successfully ✅

### 6. Optional: Generate Cosign Keys (Recommended for Production)

**Only do this when ready for production signing:**

- [ ] Install cosign: `sudo dnf install cosign` (or `brew install cosign`)
- [ ] Generate keys: `cosign generate-key-pair`
- [ ] Save password securely (needed for key generation only)
- [ ] Add `cosign.key` to GitHub Secrets as `SIGNING_SECRET`
  - [ ] Go to: https://github.com/jeyj0/jeyjos/settings/secrets/actions
  - [ ] New repository secret
  - [ ] Name: `SIGNING_SECRET`
  - [ ] Value: entire contents of `cosign.key`
- [ ] Replace `cosign.pub` in repo with your public key
- [ ] Commit and push the public key
- [ ] Edit `.github/workflows/build.yml`
- [ ] Uncomment the "Install Cosign" and "Sign container image" steps
- [ ] Commit and push changes
- [ ] Next build will produce signed images

### 7. Optional: Enable SBOM (Recommended for Production)

**Only do this after enabling image signing:**

- [ ] Image signing is enabled (step 6 above)
- [ ] Edit `.github/workflows/build.yml`
- [ ] Find "OPTIONAL: SBOM" section (around line 136)
- [ ] Uncomment "Setup Syft" step
- [ ] Uncomment "Generate SBOM" step
- [ ] Find "OPTIONAL: SBOM Attestation" section (around line 205)
- [ ] Uncomment "Add SBOM Attestation" step
- [ ] Commit and push
- [ ] Next build will include SBOM

### 8. Optional: Test Locally

**Only if you want to test before deploying:**

```bash
# Clone repository
git clone https://github.com/jeyj0/jeyjos.git
cd jeyjos

# Build locally (requires podman)
just build

# Build VM image
just build-qcow2

# Run in browser-based VM
just run-vm-qcow2
```

### 9. Optional: Deploy to a Test System

**On a compatible bootc system (Fedora Silverblue, Bluefin, etc.):**

```bash
# Switch to your image
sudo bootc switch ghcr.io/jeyj0/jeyjos:stable

# Reboot
sudo systemctl reboot

# After reboot, verify
bootc status
ujust --list
```

### 10. Optional: Customize Your OS

**Only when you want to add packages or change configuration:**

#### Add System Packages (Baked into Image)

Edit `build/10-build.sh`:

```bash
dnf5 install -y vim neovim htop
```

#### Add CLI Tools (Installed by Users)

Edit `custom/brew/default.Brewfile`:

```ruby
brew "neovim"
brew "btop"
```

#### Add GUI Apps (Installed on First Boot)

Edit `custom/flatpaks/default.preinstall`:

```ini
[Flatpak Preinstall com.visualstudio.code]
Branch=stable
```

#### Add ujust Commands

Edit `custom/ujust/custom-apps.just`:

```just
[group('Apps')]
my-command:
    echo "Hello from jeyjos!"
```

## 🎉 Success Criteria

You'll know everything is working when:

- ✅ Build workflow completes successfully (green checkmark)
- ✅ Image is available at: `ghcr.io/jeyj0/jeyjos:stable`
- ✅ You can pull the image: `podman pull ghcr.io/jeyj0/jeyjos:stable`
- ✅ Package is public (visible at https://github.com/jeyj0?tab=packages)
- ✅ Renovate creates PRs for updates (within 6 hours)

## 📚 Documentation References

- **Full Details**: See `BOOTSTRAP_COMPLETE.md` for comprehensive overview
- **README.md**: Complete setup guide with all instructions
- **GitHub Actions**: All workflow documentation in `.github/workflows/`
- **Build Scripts**: Documentation in `build/README.md`
- **Homebrew**: Guide in `custom/brew/README.md`
- **Flatpaks**: Guide in `custom/flatpaks/README.md`
- **ujust Commands**: Guide in `custom/ujust/README.md`

## 🆘 Need Help?

- **Universal Blue Discord**: https://discord.gg/WEu6BdFEtp
- **bootc Discussion**: https://github.com/bootc-dev/bootc/discussions
- **Issue with Build**: Check Actions logs for error messages
- **Issue with PR Validation**: Check which validation workflow failed

---

**Quick Start (Minimal Steps)**:

1. ✅ Merge this PR to main
2. ✅ Enable GitHub Actions permissions (read/write)
3. ✅ Wait for build to complete (~10 minutes)
4. ✅ Make package public
5. ✅ Test: `podman pull ghcr.io/jeyj0/jeyjos:stable`

**Done!** Your OS is now building and ready to deploy! 🚀
