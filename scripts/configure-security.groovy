/**
 * ============================================================================
 * Jenkins Security Configuration Script
 * ============================================================================
 *
 * @description Groovy script to configure Jenkins security automatically
 *              Run via: Jenkins > Manage Jenkins > Script Console
 *
 * @author      MR-Jenk Team
 * @version     1.0.0
 * @warning     Run this script with caution!
 *
 * @see         https://www.jenkins.io/doc/book/security/
 * ============================================================================
 */

import jenkins.model.*
import hudson.security.*
import hudson.security.csrf.DefaultCrumbIssuer
import hudson.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

// Get Jenkins instance
def instance = Jenkins.getInstance()

// =============================================================================
// 1. Security Realm configuration (Authentication)
// =============================================================================

println "🔐 Configuring authentication..."

// Use Jenkins internal user database
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(hudsonRealm)

// Create users (CUSTOMIZE BEFORE USE)
// NOTE: these credentials must be changed after first login!

// Admin account
if (!hudsonRealm.getAllUsers().find { it.id == 'admin' }) {
    hudsonRealm.createAccount('admin', 'CHANGE_ME_IMMEDIATELY')
    println "✅ User 'admin' created"
}

// Developer account
if (!hudsonRealm.getAllUsers().find { it.id == 'developer' }) {
    hudsonRealm.createAccount('developer', 'CHANGE_ME_IMMEDIATELY')
    println "✅ User 'developer' created"
}

// Viewer (read-only)
if (!hudsonRealm.getAllUsers().find { it.id == 'viewer' }) {
    hudsonRealm.createAccount('viewer', 'CHANGE_ME_IMMEDIATELY')
    println "✅ User 'viewer' created"
}

// =============================================================================
// 2. Authorization Strategy configuration (Permissions)
// =============================================================================

println "🔐 Configuring permissions..."

// Use Matrix-based security
def strategy = new GlobalMatrixAuthorizationStrategy()

// --- Permissions Admin ---
// Toutes les permissions
strategy.add(Jenkins.ADMINISTER, 'admin')

// --- Permissions Developer ---
// General read
strategy.add(Jenkins.READ, 'developer')
strategy.add(Item.READ, 'developer')
strategy.add(Item.DISCOVER, 'developer')

// Build et workspace
strategy.add(Item.BUILD, 'developer')
strategy.add(Item.CANCEL, 'developer')
strategy.add(Item.WORKSPACE, 'developer')

// Read-only access to credentials (no modification)
strategy.add(CredentialsProvider.VIEW, 'developer')

// --- Permissions Viewer ---
// Read-only
strategy.add(Jenkins.READ, 'viewer')
strategy.add(Item.READ, 'viewer')
strategy.add(Item.DISCOVER, 'viewer')

// Apply the strategy
instance.setAuthorizationStrategy(strategy)

// =============================================================================
// 3. Configuration CSRF Protection
// =============================================================================

println "🔐 Enabling CSRF protection..."

// Ensure CSRF protection is enabled
def crumbIssuer = instance.getCrumbIssuer()
if (crumbIssuer == null) {
    instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
    println "✅ CSRF protection enabled"
}

// =============================================================================
// 4. Security options configuration
// =============================================================================

println "🔐 Configuring security options..."

// Disable CLI remoting (if available)
try {
    def cli = Jenkins.getInstance().getDescriptor("jenkins.CLI")
    if (cli != null) {
        cli.enabled = false
        println "✅ CLI remoting disabled"
    }
} catch (Exception e) {
    println "⚠️  CLI configuration skipped: ${e.message}"
}

// Enable Agent → Master security (if available)
try {
    def rule = Jenkins.getInstance().injector?.getInstance(jenkins.security.s2m.AdminWhitelistRule.class)
    if (rule != null) {
        rule.setMasterKillSwitch(false)
        println "✅ Agent→Master security enabled"
    }
} catch (Exception e) {
    println "⚠️  Agent→Master config skipped: ${e.message}"
}


// =============================================================================
// 5. Save configuration
// =============================================================================

instance.save()

println ""
println "=============================================================================="
println "✅ Security configuration complete!"
println "=============================================================================="
println ""
println "⚠️  IMPORTANT: Change default passwords immediately!"
println ""
println "Created users:"
println "  - admin     (full administrator)"
println "  - developer (build + read)"
println "  - viewer    (read-only)"
println ""
println "=============================================================================="
