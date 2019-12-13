{
  apiVersion: 'argoproj.io/v1alpha1',
  metadata: {
      name: std.extVar('namespace'),
      finalizers: [
        'resources-finalizer.argocd.argoproj.io'
      ]
  },
  spec: {
    destination: {
      namespace: std.extVar('namespace'),
      server: 'https://kubernetes.default.svc'
    },
    project: 'namespace',
    source: {
      path: std.extVar('path'),
      repoURL: 'https://github.com/ribbybibby/kubernetes',
      targetRevision: 'HEAD'
    },
    syncPolicy: {
      automated: {
        prune: true,
        selfHealth: true,
      },
    },
  },
}