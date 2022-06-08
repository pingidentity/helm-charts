{{- define "pinglib.rbac.service-account.tpl" -}}
{{- $v := index . 1 -}}
{{- $isGlobal := eq "global" (default "global" $v.name) -}}
{{/* Allow for generating global RBAC objects or workload-specific objects */}}
{{- if or (and (not $isGlobal) $v.rbac.generateServiceAccount) (and $isGlobal $v.rbac.generateGlobalServiceAccount) -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  {{- include "pinglib.metadata.labels" .  | nindent 2  }}
  {{- include "pinglib.metadata.annotations" .  | nindent 2  -}}
  name: {{ include "pinglib.rbac.service-account-name" (append . $v.rbac.serviceAccountName) }}
{{- end -}}
{{- end -}}

{{- define "pinglib.rbac.role.tpl" -}}
{{- $v := index . 1 -}}
{{- $isGlobal := eq "global" (default "global" $v.name) -}}
{{/* Allow for generating global RBAC objects or workload-specific objects */}}
{{- if or (and (not $isGlobal) $v.rbac.generateRoleAndRoleBinding) (and $isGlobal $v.rbac.generateGlobalRoleAndRoleBinding) -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  {{- include "pinglib.metadata.labels" .  | nindent 2  }}
  {{- include "pinglib.metadata.annotations" .  | nindent 2  -}}
  name: {{ include "pinglib.fullname" . }}-role
{{ toYaml $v.rbac.role }}
{{- end -}}
{{- end -}}

{{- define "pinglib.rbac.role-binding.tpl" -}}
{{- $top := index . 0 -}}
{{- $v := index . 1 -}}
{{- $isGlobal := eq "global" (default "global" $v.name) -}}
{{/* Allow for generating global RBAC objects or workload-specific objects */}}
{{- if or (and (not $isGlobal) $v.rbac.generateRoleAndRoleBinding) (and $isGlobal $v.rbac.generateGlobalRoleAndRoleBinding) -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  {{- include "pinglib.metadata.labels" .  | nindent 2  }}
  {{- include "pinglib.metadata.annotations" .  | nindent 2  -}}
  name: {{ include "pinglib.fullname" . }}-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ include "pinglib.fullname" . }}-role
subjects:
- kind: ServiceAccount
  name: {{ include "pinglib.rbac.service-account-name" (append . $v.rbac.serviceAccountName) }}
  namespace: {{ $top.Release.Namespace}}
{{- end -}}
{{- end -}}

{{- define "pinglib.rbac.service-account-name" -}}
  {{- $top := index . 0 -}}
  {{- $v := index . 1 -}}
  {{- $serviceAccountName := index . 2 -}}
  {{- if or (eq "_defaultServiceAccountName_" $serviceAccountName) (not $serviceAccountName) -}}
    {{/* When using a default service account name, use the global default service account unless one is
          being generated for this specific workload. */}}
    {{- $defaultPrefix := (include "pinglib.fullname" (list $top $top.Values.global)) -}}
    {{- if $v.rbac.generateServiceAccount -}}
      {{- $defaultPrefix = (include "pinglib.fullname" (initial .)) -}}
    {{- end -}}
    {{- printf "%s-service-account" $defaultPrefix -}}
  {{- else -}}
    {{- printf $serviceAccountName -}}
  {{- end -}}
{{- end -}}

{{- define "pinglib.rbac.role" -}}
  {{- include "pinglib.merge.templates" (append . "rbac.role") -}}
{{- end -}}
{{- define "pinglib.rbac.role-binding" -}}
  {{- include "pinglib.merge.templates" (append . "rbac.role-binding") -}}
{{- end -}}
{{- define "pinglib.rbac.service-account" -}}
  {{- include "pinglib.merge.templates" (append . "rbac.service-account") -}}
{{- end -}}
