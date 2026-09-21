import React, { useCallback, useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Linking,
  Pressable,
  RefreshControl,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';

import { LinearGradient } from 'expo-linear-gradient';

import {
  getHealth,
  getStatus,
  getVersion,
} from './src/services/api';

import { theme } from './src/theme/theme';

type Screen =
  | 'Home'
  | 'Operations'
  | 'Architecture'
  | 'Terraform'
  | 'DevSecOps'
  | 'Project';

type StatusData = {
  application?: {
    name?: string;
    status?: string;
    version?: string;
  };
  deployment?: {
    environment?: string;
    platform?: string;
    region?: string;
    runtime?: string;
  };
  architecture?: {
    dns?: string;
    tls?: string;
    load_balancer?: string;
    compute?: string;
    container_registry?: string;
    infrastructure_as_code?: string;
  };
};

const architectureDomains = {
  Networking: [
    'Amazon Route 53',
    'Application Load Balancer',
    'VPC',
    'Public / Private Subnets',
  ],
  Security: [
    'AWS Certificate Manager',
    'IAM',
    'Security Groups',
    'TLS',
  ],
  Compute: [
    'Amazon EC2',
    'Auto Scaling',
    'Launch Templates',
    'Docker Runtime',
  ],
  Storage: [
    'Amazon EBS',
    'Amazon EFS',
    'Amazon S3',
    'Encrypted Storage',
  ],
  Database: [
    'Amazon RDS',
    'DynamoDB',
    'High Availability',
    'Encryption',
  ],
  Containers: [
    'Amazon ECR',
    'Docker',
    'Immutable Images',
    'Container Health Checks',
  ],
  DevSecOps: [
    'GitHub Actions',
    'Pull Requests',
    'ShellCheck',
    'Container Scanning',
  ],
  Operations: [
    'Health API',
    'Version API',
    'Status API',
    'Rolling Instance Refresh',
  ],
};

const tabs: Screen[] = [
  'Home',
  'Operations',
  'Architecture',
  'Terraform',
  'DevSecOps',
  'Project',
];

function SectionTitle({
  label,
  title,
  copy,
}: {
  label: string;
  title: string;
  copy?: string;
}) {
  return (
    <View style={styles.sectionHeader}>
      <Text style={styles.kicker}>{label}</Text>
      <Text style={styles.sectionTitle}>{title}</Text>
      {copy ? <Text style={styles.sectionCopy}>{copy}</Text> : null}
    </View>
  );
}

function Card({
  title,
  value,
  detail,
}: {
  title: string;
  value: string;
  detail?: string;
}) {
  return (
    <View style={styles.card}>
      <Text style={styles.cardLabel}>{title}</Text>
      <Text style={styles.cardValue}>{value}</Text>
      {detail ? <Text style={styles.cardDetail}>{detail}</Text> : null}
    </View>
  );
}

function ActionButton({
  label,
  onPress,
  secondary = false,
}: {
  label: string;
  onPress: () => void;
  secondary?: boolean;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={[
        styles.button,
        secondary ? styles.buttonSecondary : styles.buttonPrimary,
      ]}
    >
      <Text
        style={[
          styles.buttonText,
          secondary
            ? styles.buttonSecondaryText
            : styles.buttonPrimaryText,
        ]}
      >
        {label}
      </Text>
    </Pressable>
  );
}

export default function App() {
  const [screen, setScreen] = useState<Screen>('Home');
  const [status, setStatus] = useState<StatusData>({});
  const [health, setHealth] = useState('Checking');
  const [version, setVersion] = useState('Loading');
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [domain, setDomain] =
    useState<keyof typeof architectureDomains>('Networking');

  const refresh = useCallback(async () => {
    try {
      const [healthData, versionData, statusData] =
        await Promise.all([
          getHealth(),
          getVersion(),
          getStatus(),
        ]);

      setHealth(
        healthData.status === 'healthy'
          ? 'Healthy'
          : String(healthData.status ?? 'Unknown')
      );

      setVersion(
        String(
          versionData.version ??
          healthData.version ??
          'Unknown'
        )
      );

      setStatus(statusData);
    } catch {
      setHealth('Unavailable');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, []);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const onRefresh = () => {
    setRefreshing(true);
    refresh();
  };

  const open = async (url: string) => {
    await Linking.openURL(url);
  };

  const renderHome = () => (
    <>
      <LinearGradient
        colors={['#0b4fb3', '#1769e0', '#3d8bfd']}
        style={styles.hero}
      >
        <Text style={styles.heroKicker}>
          AWS ENTERPRISE CLOUD LAB
        </Text>

        <Text style={styles.heroTitle}>
          Cloud engineering in your pocket.
        </Text>

        <Text style={styles.heroCopy}>
          Explore a production AWS platform built with
          Terraform, containers, automated delivery and
          operational APIs.
        </Text>

        <View style={styles.actions}>
          <ActionButton
            label="Explore Architecture"
            onPress={() => setScreen('Architecture')}
          />

          <ActionButton
            label="Live Operations"
            secondary
            onPress={() => setScreen('Operations')}
          />
        </View>
      </LinearGradient>

      <SectionTitle
        label="PRODUCTION"
        title="Platform at a glance"
        copy="Live status from the production AWS environment."
      />

      <View style={styles.grid}>
        <Card
          title="HEALTH"
          value={health}
          detail="Production API"
        />

        <Card
          title="VERSION"
          value={version}
          detail="Deployed release"
        />

        <Card
          title="REGION"
          value={status.deployment?.region ?? 'us-east-1'}
          detail="AWS"
        />

        <Card
          title="RUNTIME"
          value={status.deployment?.runtime ?? 'Docker'}
          detail="Containerized"
        />
      </View>

      <View style={styles.callout}>
        <Text style={styles.calloutTitle}>
          Infrastructure as Code
        </Text>

        <Text style={styles.calloutCopy}>
          Reusable Terraform modules provision networking,
          security, compute, storage, databases and the
          production application platform.
        </Text>

        <ActionButton
          label="View Terraform"
          onPress={() => setScreen('Terraform')}
        />
      </View>
    </>
  );

  const renderOperations = () => (
    <>
      <SectionTitle
        label="OPERATIONS"
        title="Production Operations"
        copy="Live application and deployment metadata from AWS."
      />

      {loading ? (
        <ActivityIndicator
          size="large"
          color={theme.colors.primary}
        />
      ) : (
        <>
          <View style={styles.grid}>
            <Card
              title="STATUS"
              value={health}
              detail="Application health"
            />

            <Card
              title="VERSION"
              value={version}
              detail="Immutable release"
            />

            <Card
              title="ENVIRONMENT"
              value={
                status.deployment?.environment ?? 'production'
              }
            />

            <Card
              title="PLATFORM"
              value={status.deployment?.platform ?? 'AWS'}
              detail={status.deployment?.region ?? 'us-east-1'}
            />
          </View>

          <SectionTitle
            label="REQUEST PATH"
            title="Production request flow"
          />

          {[
            'Internet',
            'Amazon Route 53',
            'AWS Certificate Manager',
            'Application Load Balancer',
            'EC2 Auto Scaling',
            'Docker Application',
          ].map((item, index) => (
            <View key={item} style={styles.flowRow}>
              <View style={styles.flowNumber}>
                <Text style={styles.flowNumberText}>
                  {index + 1}
                </Text>
              </View>

              <Text style={styles.flowText}>{item}</Text>
            </View>
          ))}
        </>
      )}
    </>
  );

  const renderArchitecture = () => (
    <>
      <SectionTitle
        label="SYSTEM DESIGN"
        title="Cloud Architecture Explorer"
        copy="Explore the major engineering domains implemented by the lab."
      />

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        style={styles.domainScroll}
      >
        {Object.keys(architectureDomains).map((item) => {
          const typed =
            item as keyof typeof architectureDomains;

          return (
            <Pressable
              key={item}
              onPress={() => setDomain(typed)}
              style={[
                styles.domainButton,
                domain === typed &&
                  styles.domainButtonActive,
              ]}
            >
              <Text
                style={[
                  styles.domainButtonText,
                  domain === typed &&
                    styles.domainButtonTextActive,
                ]}
              >
                {item}
              </Text>
            </Pressable>
          );
        })}
      </ScrollView>

      <View style={styles.architectureCard}>
        <Text style={styles.architectureLabel}>
          ACTIVE ARCHITECTURE DOMAIN
        </Text>

        <Text style={styles.architectureTitle}>
          {domain}
        </Text>

        {architectureDomains[domain].map((item) => (
          <View key={item} style={styles.serviceRow}>
            <View style={styles.serviceDot} />
            <Text style={styles.serviceText}>{item}</Text>
          </View>
        ))}
      </View>
    </>
  );

  const renderTerraform = () => (
    <>
      <SectionTitle
        label="INFRASTRUCTURE AS CODE"
        title="Terraform Engineering"
        copy="AWS infrastructure expressed as reusable, reviewable and version-controlled code."
      />

      {[
        ['Networking', 'VPC, subnets, routing and gateways'],
        ['Security', 'IAM, security groups and encryption'],
        ['Compute', 'Launch templates and Auto Scaling'],
        ['Storage', 'EBS, EFS and S3'],
        ['Database', 'RDS and DynamoDB'],
        ['Containers', 'ECR and immutable application images'],
      ].map(([title, detail]) => (
        <Card
          key={title}
          title={title.toUpperCase()}
          value={title}
          detail={detail}
        />
      ))}

      <View style={styles.code}>
        <Text style={styles.codeText}>
          terraform init{'\n'}
          terraform validate{'\n'}
          terraform plan{'\n'}
          terraform apply
        </Text>
      </View>
    </>
  );

  const renderDevSecOps = () => (
    <>
      <SectionTitle
        label="DEVSECOPS"
        title="Engineering Delivery Pipeline"
        copy="Automated validation and controlled delivery from source code to production."
      />

      {[
        'Feature Branch',
        'Pull Request',
        'Repository Validation',
        'ShellCheck',
        'Container Build',
        'Security Scan',
        'Amazon ECR',
        'Terraform Deployment',
        'EC2 Instance Refresh',
        'Production Verification',
      ].map((item, index) => (
        <View key={item} style={styles.pipelineRow}>
          <View style={styles.pipelineIndex}>
            <Text style={styles.pipelineIndexText}>
              {String(index + 1).padStart(2, '0')}
            </Text>
          </View>

          <Text style={styles.pipelineText}>{item}</Text>
        </View>
      ))}
    </>
  );

  const renderProject = () => (
    <>
      <SectionTitle
        label="ENGINEERING PROJECT"
        title="AWS Enterprise Cloud Lab"
        copy="A hands-on cloud engineering portfolio covering infrastructure, automation, containers, security and operations."
      />

      <View style={styles.callout}>
        <Text style={styles.calloutTitle}>
          Qayum Sidiqi
        </Text>

        <Text style={styles.calloutCopy}>
          Network, systems and cloud infrastructure
          engineering with hands-on AWS, Terraform,
          containers and DevSecOps.
        </Text>

        <ActionButton
          label="GitHub Repository"
          onPress={() =>
            open(
              'https://github.com/sidiqi-lab-01/sidiqi-aws-enterprise-cloud-lab'
            )
          }
        />

        <ActionButton
          label="LinkedIn"
          secondary
          onPress={() =>
            open(
              'https://www.linkedin.com/in/qayum-sidiqi-853a141b9/'
            )
          }
        />

        <ActionButton
          label="Credly Certifications"
          secondary
          onPress={() =>
            open(
              'https://www.credly.com/users/qayum-sidiqi'
            )
          }
        />
      </View>
    </>
  );

  const content = () => {
    switch (screen) {
      case 'Operations':
        return renderOperations();
      case 'Architecture':
        return renderArchitecture();
      case 'Terraform':
        return renderTerraform();
      case 'DevSecOps':
        return renderDevSecOps();
      case 'Project':
        return renderProject();
      default:
        return renderHome();
    }
  };

  return (
    <SafeAreaView style={styles.safe}>
      <StatusBar
        barStyle="dark-content"
        backgroundColor={theme.colors.surface}
      />

      <View style={styles.topBar}>
        <View>
          <Text style={styles.brand}>
            AWS Enterprise Cloud Lab
          </Text>
          <Text style={styles.brandSub}>
            Production Engineering
          </Text>
        </View>

        <View
          style={[
            styles.healthBadge,
            health !== 'Healthy' &&
              styles.healthBadgeWarning,
          ]}
        >
          <Text style={styles.healthBadgeText}>
            {health}
          </Text>
        </View>
      </View>

      <ScrollView
        style={styles.main}
        contentContainerStyle={styles.mainContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
          />
        }
      >
        {content()}

        <Text style={styles.footer}>
          AWS • Terraform • DevSecOps • Containers
        </Text>
      </ScrollView>

      <View style={styles.bottomNav}>
        {tabs.map((item) => (
          <Pressable
            key={item}
            onPress={() => setScreen(item)}
            style={[
              styles.navItem,
              screen === item && styles.navItemActive,
            ]}
          >
            <Text
              numberOfLines={1}
              style={[
                styles.navText,
                screen === item && styles.navTextActive,
              ]}
            >
              {item === 'Architecture'
                ? 'Arch'
                : item === 'Operations'
                ? 'Ops'
                : item}
            </Text>
          </Pressable>
        ))}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: theme.colors.surface,
  },

  main: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },

  mainContent: {
    paddingBottom: 30,
  },

  topBar: {
    paddingHorizontal: 18,
    paddingVertical: 12,
    backgroundColor: theme.colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.border,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },

  brand: {
    color: theme.colors.text,
    fontSize: 16,
    fontWeight: '800',
  },

  brandSub: {
    marginTop: 2,
    color: theme.colors.muted,
    fontSize: 11,
  },

  healthBadge: {
    backgroundColor: '#dcfce7',
    borderRadius: 20,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },

  healthBadgeWarning: {
    backgroundColor: '#fee2e2',
  },

  healthBadgeText: {
    color: theme.colors.success,
    fontSize: 11,
    fontWeight: '800',
  },

  hero: {
    margin: 16,
    padding: 24,
    borderRadius: 24,
  },

  heroKicker: {
    color: '#dbeafe',
    fontSize: 11,
    fontWeight: '800',
    letterSpacing: 1.4,
  },

  heroTitle: {
    marginTop: 12,
    color: '#ffffff',
    fontSize: 34,
    lineHeight: 40,
    fontWeight: '900',
  },

  heroCopy: {
    marginTop: 14,
    color: '#eaf2ff',
    fontSize: 15,
    lineHeight: 23,
  },

  actions: {
    marginTop: 20,
    gap: 10,
  },

  button: {
    borderRadius: 12,
    paddingHorizontal: 16,
    paddingVertical: 13,
    alignItems: 'center',
    marginTop: 10,
  },

  buttonPrimary: {
    backgroundColor: '#ffffff',
  },

  buttonSecondary: {
    backgroundColor: 'rgba(255,255,255,0.13)',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.45)',
  },

  buttonText: {
    fontWeight: '800',
  },

  buttonPrimaryText: {
    color: theme.colors.primaryDark,
  },

  buttonSecondaryText: {
    color: '#ffffff',
  },

  sectionHeader: {
    paddingHorizontal: 18,
    marginTop: 26,
    marginBottom: 14,
  },

  kicker: {
    color: theme.colors.primary,
    fontSize: 11,
    fontWeight: '900',
    letterSpacing: 1.2,
  },

  sectionTitle: {
    marginTop: 6,
    color: theme.colors.text,
    fontSize: 27,
    lineHeight: 33,
    fontWeight: '900',
  },

  sectionCopy: {
    marginTop: 8,
    color: theme.colors.muted,
    fontSize: 14,
    lineHeight: 21,
  },

  grid: {
    paddingHorizontal: 16,
    gap: 12,
  },

  card: {
    marginHorizontal: 16,
    marginBottom: 12,
    padding: 18,
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radius.md,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },

  cardLabel: {
    color: theme.colors.muted,
    fontSize: 10,
    fontWeight: '900',
    letterSpacing: 1.1,
  },

  cardValue: {
    marginTop: 7,
    color: theme.colors.text,
    fontSize: 20,
    fontWeight: '900',
  },

  cardDetail: {
    marginTop: 5,
    color: theme.colors.muted,
    fontSize: 13,
  },

  callout: {
    margin: 16,
    padding: 20,
    backgroundColor: theme.colors.dark,
    borderRadius: 20,
  },

  calloutTitle: {
    color: '#ffffff',
    fontSize: 22,
    fontWeight: '900',
  },

  calloutCopy: {
    marginTop: 10,
    color: '#cbd5e1',
    lineHeight: 21,
  },

  flowRow: {
    marginHorizontal: 16,
    marginBottom: 10,
    padding: 14,
    backgroundColor: theme.colors.surface,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: theme.colors.border,
    flexDirection: 'row',
    alignItems: 'center',
  },

  flowNumber: {
    width: 30,
    height: 30,
    borderRadius: 15,
    backgroundColor: theme.colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },

  flowNumberText: {
    color: '#ffffff',
    fontWeight: '900',
  },

  flowText: {
    marginLeft: 12,
    color: theme.colors.text,
    fontWeight: '700',
  },

  domainScroll: {
    paddingLeft: 16,
    marginBottom: 16,
  },

  domainButton: {
    marginRight: 8,
    paddingHorizontal: 14,
    paddingVertical: 9,
    borderRadius: 20,
    backgroundColor: theme.colors.surface,
    borderWidth: 1,
    borderColor: theme.colors.border,
  },

  domainButtonActive: {
    backgroundColor: theme.colors.primary,
    borderColor: theme.colors.primary,
  },

  domainButtonText: {
    color: theme.colors.text,
    fontWeight: '700',
    fontSize: 12,
  },

  domainButtonTextActive: {
    color: '#ffffff',
  },

  architectureCard: {
    margin: 16,
    padding: 20,
    backgroundColor: theme.colors.dark,
    borderRadius: 20,
  },

  architectureLabel: {
    color: '#93c5fd',
    fontSize: 10,
    fontWeight: '900',
    letterSpacing: 1.2,
  },

  architectureTitle: {
    marginTop: 7,
    marginBottom: 15,
    color: '#ffffff',
    fontSize: 26,
    fontWeight: '900',
  },

  serviceRow: {
    paddingVertical: 11,
    flexDirection: 'row',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: '#263247',
  },

  serviceDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: '#60a5fa',
  },

  serviceText: {
    marginLeft: 12,
    color: '#e2e8f0',
    fontWeight: '600',
  },

  code: {
    margin: 16,
    padding: 20,
    borderRadius: 18,
    backgroundColor: '#08111f',
  },

  codeText: {
    color: '#93c5fd',
    fontFamily: 'monospace',
    fontSize: 14,
    lineHeight: 25,
  },

  pipelineRow: {
    marginHorizontal: 16,
    marginBottom: 10,
    padding: 14,
    backgroundColor: theme.colors.surface,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: theme.colors.border,
    flexDirection: 'row',
    alignItems: 'center',
  },

  pipelineIndex: {
    width: 36,
    height: 36,
    borderRadius: 10,
    backgroundColor: '#dbeafe',
    alignItems: 'center',
    justifyContent: 'center',
  },

  pipelineIndexText: {
    color: theme.colors.primaryDark,
    fontWeight: '900',
  },

  pipelineText: {
    marginLeft: 13,
    color: theme.colors.text,
    fontWeight: '700',
  },

  bottomNav: {
    backgroundColor: theme.colors.surface,
    borderTopWidth: 1,
    borderTopColor: theme.colors.border,
    paddingHorizontal: 4,
    paddingTop: 7,
    paddingBottom: 8,
    flexDirection: 'row',
  },

  navItem: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 8,
    borderRadius: 10,
  },

  navItemActive: {
    backgroundColor: '#eaf2ff',
  },

  navText: {
    color: theme.colors.muted,
    fontSize: 10,
    fontWeight: '700',
  },

  navTextActive: {
    color: theme.colors.primary,
    fontWeight: '900',
  },

  footer: {
    marginTop: 24,
    paddingHorizontal: 18,
    textAlign: 'center',
    color: theme.colors.muted,
    fontSize: 11,
  },
});
