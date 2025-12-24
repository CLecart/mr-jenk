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
import hudson.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import org.jenkinsci.plugins.plaincredentials.impl.*
import hudson.util.Secret

// Get Jenkins instance
def instance = Jenkins.getInstance()

// =============================================================================
// 1. Configuration du Security Realm (Authentification)
// =============================================================================

println "🔐 Configuring authentication..."

// Use Jenkins internal user database
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(hudsonRealm)

// Create users (CUSTOMIZE BEFORE USE)
// NOTE: these credentials must be changed after first login!

// Admin principal
if (!hudsonRealm.getAllUsers().find { it.id == 'admin' }) {
    hudsonRealm.createAccount('admin', 'CHANGE_ME_IMMEDIATELY')
    println "✅ User 'admin' created"
}

// Développeur
if (!hudsonRealm.getAllUsers().find { it.id == 'developer' }) {
    hudsonRealm.createAccount('developer', 'CHANGE_ME_IMMEDIATELY')
    println "✅ User 'developer' created"
}

// Viewer (lecture seule)
if (!hudsonRealm.getAllUsers().find { it.id == 'viewer' }) {
    hudsonRealm.createAccount('viewer', 'CHANGE_ME_IMMEDIATELY')
    println "✅ User 'viewer' created"
}

// =============================================================================
// 2. Configuration de l'Authorization Strategy (Permissions)
// =============================================================================

println "🔐 Configuring permissions..."

// Utiliser Matrix-based security
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

// Appliquer la stratégie
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
// 4. Configuration des options de sécurité
// =============================================================================

println "🔐 Configuring security options..."

// Disable CLI remoting
jenkins.CLI.get().enabled = false

// Enable Agent → Master security
instance.injector.getInstance(jenkins.security.s2m.AdminWhitelistRule.class)
    .setMasterKillSwitch(false)

// =============================================================================
// 5. Sauvegarder la configuration
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
