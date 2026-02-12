# jeyjos

A template for building custom bootc operating system images based on the lessons from [Universal Blue](https://universal-blue.org/) and [Bluefin](https://projectbluefin.io). It is designed to be used manually, but is optimized to be bootstraped by GitHub Copilot. After set up you'll have your own custom Linux.

This template uses the **multi-stage build architecture** from , combining resources from multiple OCI containers for modularity and maintainability. See the [Architecture](#architecture) section below for details.

**Unlike previous templates, you are not modifying Bluefin and making changes.**: You are assembling your own Bluefin in the same exact way that Bluefin, Aurora, and Bluefin LTS are built. This is way more flexible and better for everyone since the image-agnostic and desktop things we love about Bluefin lives in @projectbluefin/common.

Instead, you create your own OS repository based on this template, allowing full customization while leveraging Bluefin's robust build system and shared components.

> Be the one who moves, not the one who is moved.

## What Makes jeyjos Different?

Here are the changes from the base Silverblue image. This image is based on [Universal Blue Silverblue](https://github.com/ublue-os/silverblue) and includes these customizations:

### Base Configuration

- **Base Image**: `ghcr.io/ublue-os/silverblue-main:latest` (Fedora with GNOME)
- **Architecture**: Multi-stage build using OCI containers from @projectbluefin/common and @ublue-os/brew
- **Build System**: Automated via GitHub Actions with Renovate for dependency updates

### Added Packages (Build-time)

- Currently using default build configuration
- System packages can be added via `build/10-build.sh`

### Added Applications (Runtime)

- **CLI Tools (Homebrew)**: Configured via Brewfiles in `custom/brew/`
- **GUI Apps (Flatpak)**: Configured via preinstall files in `custom/flatpaks/`

### Configuration Changes

- Standard Universal Blue configuration
- ujust commands available for system management
- Homebrew integration for CLI tools

_This is a fresh bootstrap. Customize by adding packages to build scripts, Brewfiles, and Flatpak preinstall files._

_Last updated: 2026-02-12_

## Guided Copilot Mode

Here are the steps to guide copilot to make your own repo, or just use it like a regular image template.

1. Click the green "Use this as a template" button and create a new repository
2. Select your owner, pick a repo name for your OS, and a description
3. In the "Jumpstart your project with Copilot (optional)" add this, modify to your liking:

```
Use @projectbluefin/finpilot as a template, name the OS the repository name. Ensure the entire operating system is bootstrapped. Ensure all github actions are enabled and running.  Ensure the README has the github setup instructions for cosign and the other steps required to finish the task.
```

## What's Included

### Build System

- Automated builds via GitHub Actions on every commit
- Awesome self hosted Renovate setup that keeps all your images and actions up to date.
- Automatic cleanup of old images (90+ days) to keep it tidy
- Pull request workflow - test changes before merging to main
  - PRs build and validate before merge
  - `main` branch builds `:stable` images
- Validates your files on pull requests so you never break a build:
  - Brewfile, Justfile, ShellCheck, Renovate config, and it'll even check to make sure the flatpak you add exists on FlatHub
- Production Grade Features
  - Container signing and SBOM Generation
  - See checklist below to enable these as they take some manual configuration

### Homebrew Integration

- Pre-configured Brewfiles for easy package installation and customization
- Includes curated collections: development tools, fonts, CLI utilities. Go nuts.
- Users install packages at runtime with `brew bundle`, aliased to premade `ujust commands`
- See [custom/brew/README.md](custom/brew/README.md) for details

### Flatpak Support

- Ship your favorite flatpaks
- Automatically installed on first boot after user setup
- See [custom/flatpaks/README.md](custom/flatpaks/README.md) for details

### ujust Commands

- User-friendly command shortcuts via `ujust`
- Pre-configured examples for app installation and system maintenance for you to customize
- See [custom/ujust/README.md](custom/ujust/README.md) for details

### Build Scripts

- Modular numbered scripts (10-, 20-, 30-) run in order
- Example scripts included for third-party repositories and desktop replacement
- Helper functions for safe COPR usage
- See [build/README.md](build/README.md) for details

## Quick Start

### 1. Create Your Repository

Click "Use this template" to create a new repository from this template.

### 2. Rename the Project

Important: Change `finpilot` to your repository name in these 6 files:

1. `Containerfile` (line 4): `# Name: your-repo-name`
2. `Justfile` (line 1): `export image_name := env("IMAGE_NAME", "your-repo-name")`
3. `README.md` (line 1): `# your-repo-name`
4. `artifacthub-repo.yml` (line 5): `repositoryID: your-repo-name`
5. `custom/ujust/README.md` (~line 175): `localhost/your-repo-name:stable`
6. `.github/workflows/clean.yml` (line 23): `packages: your-repo-name`

### 3. Enable GitHub Actions

GitHub Actions are required to build your operating system image. Follow these steps to enable them:

1. **Navigate to Actions tab**:
   - Go to your repository on GitHub
   - Click the "Actions" tab at the top
2. **Enable workflows**:
   - Click the green button "I understand my workflows, go ahead and enable them"
3. **Verify workflow enablement**:

   - You should see several workflows listed:
     - **Build container image** - Builds your OS image
     - **Cleanup Old Images** - Manages image retention
     - **Renovate** - Keeps dependencies updated
     - **Validate-\*** workflows - Pre-merge checks (shellcheck, Brewfile, Flatpak, etc.)

4. **Trigger your first build**:

   - Your first build will start automatically on the next push to `main`
   - Or manually trigger it: Actions tab → "Build container image" → "Run workflow"

5. **Monitor the build**:
   - Click on "Build container image" workflow
   - Watch the build progress (typically takes 5-15 minutes)
   - Once complete, your image will be available at: `ghcr.io/jeyj0/jeyjos:stable`

**Important Notes**:

- Image signing is **disabled by default**. Your images will build successfully without any signing keys
- The image will be publicly accessible at `ghcr.io/your-username/jeyjos:stable`
- Once ready for production, see "Optional: Enable Image Signing" section below

### 4. Customize Your Image

Choose your base image in `Containerfile` (line 23):

```dockerfile
FROM ghcr.io/ublue-os/bluefin:stable
```

Add your packages in `build/10-build.sh`:

```bash
dnf5 install -y package-name
```

Customize your apps:

- Add Brewfiles in `custom/brew/` ([guide](custom/brew/README.md))
- Add Flatpaks in `custom/flatpaks/` ([guide](custom/flatpaks/README.md))
- Add ujust commands in `custom/ujust/` ([guide](custom/ujust/README.md))

### 5. Development Workflow

All changes should be made via pull requests:

1. Open a pull request on GitHub with the change you want.
2. The PR will automatically trigger:
   - Build validation
   - Brewfile, Flatpak, Justfile, and shellcheck validation
   - Test image build
3. Once checks pass, merge the PR
4. Merging triggers publishes a `:stable` image

### 6. Deploy Your Image

Switch to your image:

```bash
sudo bootc switch ghcr.io/your-username/your-repo-name:stable
sudo systemctl reboot
```

## Optional: Enable Image Signing

Image signing is disabled by default to let you start building immediately. However, signing is strongly recommended for production use.

### Why Sign Images?

- Verify image authenticity and integrity
- Prevent tampering and supply chain attacks
- Required for some enterprise/security-focused deployments
- Industry best practice for production images

### Prerequisites

Install cosign on your local machine:

```bash
# On Fedora/RHEL
sudo dnf install cosign

# On Ubuntu/Debian
sudo apt install cosign

# Or using Homebrew
brew install cosign

# Or download from releases
# https://github.com/sigstore/cosign/releases
```

### Setup Instructions

#### Step 1: Generate Signing Keys

Run cosign to generate a key pair:

```bash
cosign generate-key-pair
```

You'll be prompted for a password to protect the private key. Choose a strong password.

This creates two files:

- `cosign.key` (private key) - **Keep this secret! Never commit to git!**
- `cosign.pub` (public key) - This will be committed to your repository

#### Step 2: Add Private Key to GitHub Secrets

1. **Copy the private key contents**:

   ```bash
   cat cosign.key
   ```

   Copy the entire output (including `-----BEGIN ENCRYPTED COSIGN PRIVATE KEY-----` and `-----END ENCRYPTED COSIGN PRIVATE KEY-----`)

2. **Navigate to GitHub Secrets**:

   - Go to your repository on GitHub: https://github.com/jeyj0/jeyjos
   - Click "Settings" tab
   - In the left sidebar, click "Secrets and variables" → "Actions"
   - Click the green "New repository secret" button

3. **Create the secret**:

   - Name: `SIGNING_SECRET`
   - Secret: Paste the entire contents of `cosign.key`
   - Click "Add secret"

4. **Verify the secret**:
   - You should see `SIGNING_SECRET` listed in your repository secrets
   - The value will be hidden for security

**📚 Documentation**: [GitHub Encrypted Secrets Guide](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)

#### Step 3: Update Public Key in Repository

Replace the placeholder public key with your actual key:

```bash
# Copy your public key to the repository
cp cosign.pub /path/to/jeyjos/cosign.pub

# Commit and push
git add cosign.pub
git commit -m "chore: update cosign public key"
git push
```

#### Step 4: Enable Signing in Workflow

1. **Edit the build workflow**:

   ```bash
   # Open in your editor
   vim .github/workflows/build.yml
   # Or use GitHub's web editor
   ```

2. **Find the signing section** (around line 178):

   ```yaml
   # OPTIONAL: Image Signing with Cosign
   # Signing is disabled by default. To enable, see README.md
   ```

3. **Uncomment these steps** (remove the `#` at the start of each line):

   ```yaml
   - name: Install Cosign
     uses: sigstore/cosign-installer@d7543c93d881b35a8faa02e8e3605f69b7a1ce62 # v3.10.0
     if: github.event_name != 'pull_request' && github.ref == format('refs/heads/{0}', github.event.repository.default_branch)

   - name: Sign container image
     if: github.event_name != 'pull_request' && github.ref == format('refs/heads/{0}', github.event.repository.default_branch)
     run: |
       IMAGE_FULL="${{ env.IMAGE_REGISTRY }}/${{ env.IMAGE_NAME }}"
       for tag in ${{ steps.metadata.outputs.tags }}; do
         cosign sign -y --key env://COSIGN_PRIVATE_KEY $IMAGE_FULL:$tag
       done
     env:
       TAGS: ${{ steps.push.outputs.digest }}
       COSIGN_EXPERIMENTAL: false
       COSIGN_PRIVATE_KEY: ${{ secrets.SIGNING_SECRET }}
   ```

4. **Commit and push**:
   ```bash
   git add .github/workflows/build.yml
   git commit -m "feat: enable image signing with cosign"
   git push
   ```

#### Step 5: Verify Signing Works

1. **Trigger a build**:

   - Push a change to main, or
   - Manually trigger the workflow: Actions → "Build container image" → "Run workflow"

2. **Check the workflow logs**:

   - Go to Actions tab
   - Click on the running/completed workflow
   - Verify the "Install Cosign" and "Sign container image" steps completed successfully

3. **Verify the signature** (on your local machine or bootc system):

   ```bash
   # Download the public key from your repo
   curl -sL https://raw.githubusercontent.com/jeyj0/jeyjos/main/cosign.pub -o cosign.pub

   # Verify the image signature
   cosign verify --key cosign.pub ghcr.io/jeyj0/jeyjos:stable
   ```

   You should see output like:

   ```
   Verification for ghcr.io/jeyj0/jeyjos:stable --
   The following checks were performed on each of these signatures:
     - The cosign claims were validated
     - The signatures were verified against the specified public key
   ```

### Troubleshooting

**Error: "secret SIGNING_SECRET not found"**

- Verify you created the secret with exact name `SIGNING_SECRET`
- Check Settings → Secrets and variables → Actions

**Error: "verification failed"**

- Ensure `cosign.pub` in the repository matches your generated public key
- Verify the workflow completed the signing step successfully

**Error: "password required"**

- The workflow uses the secret directly; no password prompt
- Ensure you copied the entire contents of `cosign.key` including headers

### Important Security Notes

- ⚠️ **Never commit `cosign.key`** to your repository (it's already in `.gitignore`)
- ⚠️ **Never share your private key** or the password used to encrypt it
- ✅ **Do commit `cosign.pub`** so users can verify your images
- ✅ **Backup your `cosign.key`** securely (password manager, encrypted storage)
- ✅ If compromised, generate a new key pair and update GitHub secrets

## Post-Setup Verification

After enabling GitHub Actions and completing the initial setup, verify everything is working correctly:

### 1. Check Workflow Status

Visit your Actions tab: https://github.com/jeyj0/jeyjos/actions

You should see:

- ✅ **Build container image** - Successfully completed (green checkmark)
- ✅ **Renovate** - Running periodically to update dependencies
- ✅ All **Validate-\*** workflows ready for PRs

### 2. Verify Container Image

Check that your image was published to GitHub Container Registry:

1. **Visit your packages**: https://github.com/jeyj0?tab=packages
2. **Find jeyjos package**: Should show `ghcr.io/jeyj0/jeyjos`
3. **Check tags**: Should include `:stable` and date-stamped tags

Or check via command line:

```bash
# Check if image is accessible
podman pull ghcr.io/jeyj0/jeyjos:stable

# Inspect the image
podman inspect ghcr.io/jeyj0/jeyjos:stable
```

### 3. Test Local Build (Optional)

Test building the image locally before deploying:

```bash
# Clone your repository
git clone https://github.com/jeyj0/jeyjos.git
cd jeyjos

# Build the image locally
just build

# Build a VM image for testing
just build-qcow2

# Run the VM (opens in browser)
just run-vm-qcow2
```

### 4. Verify Renovate

Check that Renovate is configured and running:

1. **Check workflow runs**: Actions → Renovate (should run every 6 hours)
2. **Look for PRs**: Renovate will create PRs for dependency updates
3. **Verify configuration**: `.github/renovate.json5` should exist

### 5. Test Validation Workflows

Create a test PR to ensure validation workflows work:

```bash
# Create a test branch
git checkout -b test-validation

# Make a trivial change
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "test: verify CI validation"
git push origin test-validation
```

Then:

1. Open a PR on GitHub
2. Verify these checks run automatically:
   - ✅ Shellcheck validation
   - ✅ Brewfile validation
   - ✅ Flatpak validation
   - ✅ Justfile validation
   - ✅ Renovate config validation

### 6. Deploy and Test (Final Step)

Once everything is verified, deploy to a test system:

```bash
# On a Fedora Silverblue, Bluefin, or compatible bootc system
sudo bootc switch ghcr.io/jeyj0/jeyjos:stable

# Reboot to apply
sudo systemctl reboot

# After reboot, verify
bootc status
ujust --list
```

### Common Issues and Solutions

**Issue: "Actions not enabled"**

- Solution: Go to Settings → Actions → General → Enable "Allow all actions and reusable workflows"

**Issue: "Package not found" when pulling image**

- Solution: Check Settings → Actions → General → Workflow permissions → Enable "Read and write permissions"
- Also check: Package settings → Change package visibility to "Public"

**Issue: "Build fails on first run"**

- Solution: Check Actions tab → Click failed workflow → Review error logs
- Common fix: Ensure all workflow files are properly committed

**Issue: "Image builds but can't pull"**

- Solution: Make package public: Package settings → Change visibility → Public

### Next Steps

✅ **Setup Complete!** Your jeyjos operating system is now:

- Building automatically on every push to main
- Publishing to GitHub Container Registry
- Validating changes via PRs
- Updating dependencies via Renovate

**Ready to customize?**

- Add packages to `build/10-build.sh`
- Configure Brewfiles in `custom/brew/`
- Set up Flatpaks in `custom/flatpaks/`
- Create ujust shortcuts in `custom/ujust/`
- See detailed guides in [Detailed Guides](#detailed-guides) section

**Ready for production?**

- See [Love Your Image? Let's Go to Production](#love-your-image-lets-go-to-production) section
- Enable image signing for security
- Enable SBOM attestation
- Consider image rechunking for optimal updates

## Love Your Image? Let's Go to Production

Ready to take your custom OS to production? Enable these features for enhanced security, reliability, and performance:

### Production Checklist

- [ ] **Enable Image Signing** (Recommended)

  - Provides cryptographic verification of your images
  - Prevents tampering and ensures authenticity
  - See "Optional: Enable Image Signing" section above for setup instructions
  - Status: **Disabled by default** to allow immediate testing

- [ ] **Enable SBOM Attestation** (Recommended)

  - Generates Software Bill of Materials for supply chain security
  - Provides transparency about what's in your image
  - Requires image signing to be enabled first
  - To enable:
    1. First complete image signing setup above
    2. Edit `.github/workflows/build.yml`
    3. Find the "OPTIONAL: SBOM Attestation" section around line 232
    4. Uncomment the "Add SBOM Attestation" step
    5. Commit and push
  - Status: **Disabled by default** (requires signing first)

- [ ] **Enable Image Rechunking** (Recommended)
  - Optimizes bootc image layers for better update performance
  - Reduces update sizes by 5-10x
  - Improves download resumability with evenly sized layers
  - To enable:
    1. Edit `.github/workflows/build.yml`
    2. Find the "Build Image" step
    3. Add a rechunk step after the build (see example below)
  - Status: **Not enabled by default** (optional optimization)

#### Adding Image Rechunking

After building your bootc image, add a rechunk step before pushing to the registry. Here's an example based on the workflow used by [zirconium-dev/zirconium](https://github.com/zirconium-dev/zirconium):

```yaml
- name: Build image
  id: build
  run: sudo podman build -t "${IMAGE_NAME}:${DEFAULT_TAG}" -f ./Containerfile .

- name: Rechunk Image
  run: |
    sudo podman run --rm --privileged \
      -v /var/lib/containers:/var/lib/containers \
      --entrypoint /usr/libexec/bootc-base-imagectl \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      rechunk --max-layers 96 \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}"

- name: Push to Registry
  run: sudo podman push "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" "${IMAGE_REGISTRY}/${IMAGE_NAME}:${DEFAULT_TAG}"
```

Alternative approach using a temporary tag for clarity:

```yaml
- name: Rechunk Image
  run: |
    sudo podman run --rm --privileged \
      -v /var/lib/containers:/var/lib/containers \
      --entrypoint /usr/libexec/bootc-base-imagectl \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      rechunk --max-layers 67 \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}" \
      "localhost/${IMAGE_NAME}:${DEFAULT_TAG}-rechunked"

    # Tag the rechunked image with the original tag
    sudo podman tag "localhost/${IMAGE_NAME}:${DEFAULT_TAG}-rechunked" "localhost/${IMAGE_NAME}:${DEFAULT_TAG}"
    sudo podman rmi "localhost/${IMAGE_NAME}:${DEFAULT_TAG}-rechunked"
```

**Parameters:**

- `--max-layers`: Maximum number of layers for the rechunked image (typically 67 for optimal balance)
- The first image reference is the source (input)
- The second image reference is the destination (output)
  - When using the same reference for both, the image is rechunked in-place
  - You can also use different tags (e.g., `-rechunked` suffix) and then retag if preferred

**References:**

- [CoreOS rpm-ostree build-chunked-oci documentation](https://coreos.github.io/rpm-ostree/build-chunked-oci/)
- [bootc documentation](https://containers.github.io/bootc/)

### After Enabling Production Features

Your workflow will:

- Sign all images with your key
- Generate and attach SBOMs
- Provide full supply chain transparency

Users can verify your images with:

```bash
cosign verify --key cosign.pub ghcr.io/your-username/your-repo-name:stable
```

## Detailed Guides

- [Homebrew/Brewfiles](custom/brew/README.md) - Runtime package management
- [Flatpak Preinstall](custom/flatpaks/README.md) - GUI application setup
- [ujust Commands](custom/ujust/README.md) - User convenience commands
- [Build Scripts](build/README.md) - Build-time customization

## Architecture

This template follows the **multi-stage build architecture** from @projectbluefin/distroless, as documented in the [Bluefin Contributing Guide](https://docs.projectbluefin.io/contributing/).

### Multi-Stage Build Pattern

**Stage 1: Context (ctx)** - Combines resources from multiple sources:

- Local build scripts (`/build`)
- Local custom files (`/custom`)
- **@projectbluefin/common** - Desktop configuration shared with Aurora
- **@projectbluefin/branding** - Branding assets
- **@ublue-os/artwork** - Artwork shared with Aurora and Bazzite
- **@ublue-os/brew** - Homebrew integration

**Stage 2: Base Image** - Default options:

- `ghcr.io/ublue-os/silverblue-main:latest` (Fedora-based, default)
- `quay.io/centos-bootc/centos-bootc:stream10` (CentOS-based alternative)

### Benefits of This Architecture

- **Modularity**: Compose your image from reusable OCI containers
- **Maintainability**: Update shared components independently
- **Reproducibility**: Renovate automatically updates OCI tags to SHA digests
- **Consistency**: Share components across Bluefin, Aurora, and custom images

### OCI Container Resources

The template imports files from these OCI containers at build time:

```dockerfile
COPY --from=ghcr.io/ublue-os/base-main:latest /system_files /oci/base
COPY --from=ghcr.io/projectbluefin/common:latest /system_files /oci/common
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /oci/brew
```

Your build scripts can access these files at:

- `/ctx/oci/base/` - Base system configuration
- `/ctx/oci/common/` - Shared desktop configuration
- `/ctx/oci/branding/` - Branding assets
- `/ctx/oci/artwork/` - Artwork files
- `/ctx/oci/brew/` - Homebrew integration files

**Note**: Renovate automatically updates `:latest` tags to SHA digests for reproducible builds.

## Local Testing

Test your changes before pushing:

```bash
just build              # Build container image
just build-qcow2        # Build VM disk image
just run-vm-qcow2       # Test in browser-based VM
```

## Community

- [Universal Blue Discord](https://discord.gg/WEu6BdFEtp)
- [bootc Discussion](https://github.com/bootc-dev/bootc/discussions)

## Learn More

- [Universal Blue Documentation](https://universal-blue.org/)
- [bootc Documentation](https://containers.github.io/bootc/)
- [Video Tutorial by TesterTech](https://www.youtube.com/watch?v=IxBl11Zmq5wE)

## Security

This template provides security features for production use:

- Optional SBOM generation (Software Bill of Materials) for supply chain transparency
- Optional image signing with cosign for cryptographic verification
- Automated security updates via Renovate
- Build provenance tracking

These security features are disabled by default to allow immediate testing. When you're ready for production, see the "Love Your Image? Let's Go to Production" section above to enable them.
