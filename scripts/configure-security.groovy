/**
 * ============================================================================
 * Jenkins Security Configuration Script
 * ============================================================================
 *
 * @description Script Groovy pour configurer la sécurité Jenkins automatiquement
 *              À exécuter via: Jenkins > Manage Jenkins > Script Console
 *
 * @author      MR-Jenk Team
 * @version     1.0.0
 * @warning     Exécuter ce script avec précaution !
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

// Récupérer l'instance Jenkins
def instance = Jenkins.getInstance()

// =============================================================================
// 1. Configuration du Security Realm (Authentification)
// =============================================================================

println "🔐 Configuration de l'authentification..."

// Utiliser la base de données interne Jenkins
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(hudsonRealm)

// Créer les utilisateurs (À PERSONNALISER)
// NOTE: Ces credentials doivent être changés après le premier login !

// Admin principal
if (!hudsonRealm.getAllUsers().find { it.id == 'admin' }) {
    hudsonRealm.createAccount('admin', 'CHANGE_ME_IMMEDIATELY')
    println "✅ Utilisateur 'admin' créé"
}

// Développeur
if (!hudsonRealm.getAllUsers().find { it.id == 'developer' }) {
    hudsonRealm.createAccount('developer', 'CHANGE_ME_IMMEDIATELY')
    println "✅ Utilisateur 'developer' créé"
}

// Viewer (lecture seule)
if (!hudsonRealm.getAllUsers().find { it.id == 'viewer' }) {
    hudsonRealm.createAccount('viewer', 'CHANGE_ME_IMMEDIATELY')
    println "✅ Utilisateur 'viewer' créé"
}

// =============================================================================
// 2. Configuration de l'Authorization Strategy (Permissions)
// =============================================================================

println "🔐 Configuration des permissions..."

// Utiliser Matrix-based security
def strategy = new GlobalMatrixAuthorizationStrategy()

// --- Permissions Admin ---
// Toutes les permissions
strategy.add(Jenkins.ADMINISTER, 'admin')

// --- Permissions Developer ---
// Lecture générale
strategy.add(Jenkins.READ, 'developer')
strategy.add(Item.READ, 'developer')
strategy.add(Item.DISCOVER, 'developer')

// Build et workspace
strategy.add(Item.BUILD, 'developer')
strategy.add(Item.CANCEL, 'developer')
strategy.add(Item.WORKSPACE, 'developer')

// Lecture des credentials (pas modification)
strategy.add(CredentialsProvider.VIEW, 'developer')

// --- Permissions Viewer ---
// Lecture seule
strategy.add(Jenkins.READ, 'viewer')
strategy.add(Item.READ, 'viewer')
strategy.add(Item.DISCOVER, 'viewer')

// Appliquer la stratégie
instance.setAuthorizationStrategy(strategy)

// =============================================================================
// 3. Configuration CSRF Protection
// =============================================================================

println "🔐 Activation de la protection CSRF..."

// S'assurer que la protection CSRF est activée
def crumbIssuer = instance.getCrumbIssuer()
if (crumbIssuer == null) {
    instance.setCrumbIssuer(new DefaultCrumbIssuer(true))
    println "✅ Protection CSRF activée"
}

// =============================================================================
// 4. Configuration des options de sécurité
// =============================================================================

println "🔐 Configuration des options de sécurité..."

// Désactiver CLI remoting
jenkins.CLI.get().enabled = false

// Activer Agent → Master Security
instance.injector.getInstance(jenkins.security.s2m.AdminWhitelistRule.class)
    .setMasterKillSwitch(false)

// =============================================================================
// 5. Sauvegarder la configuration
// =============================================================================

instance.save()

println ""
println "=============================================================================="
println "✅ Configuration de sécurité terminée!"
println "=============================================================================="
println ""
println "⚠️  IMPORTANT: Changez immédiatement les mots de passe par défaut!"
println ""
println "Utilisateurs créés:"
println "  - admin     (Administrateur complet)"
println "  - developer (Build et lecture)"
println "  - viewer    (Lecture seule)"
println ""
println "=============================================================================="
