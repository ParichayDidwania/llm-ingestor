{{/*
Expand the name of the chart.
*/}}
{{- define "llm-ingestor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "llm-ingestor.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "llm-ingestor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "llm-ingestor.labels" -}}
helm.sh/chart: {{ include "llm-ingestor.chart" . }}
{{ include "llm-ingestor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: 'llm-ingestor'
{{- end }}

{{/*
Database host name
*/}}
{{- define "llm-ingestor.database.hostname" -}}
{{- printf "%s" .Values.db.config.host | trim }}
{{- end }}

{{/*
Database volume storage class name
*/}}
{{- define "llm-ingestor.database.storageClassName" -}}
{{- if .Values.db.volume.ebs -}}
{{ include "llm-ingestor.fullname" . }}-db-storage
{{- else -}}
""
{{- end }}
{{- end }}
{{/*
Selector labels
*/}}
{{- define "llm-ingestor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "llm-ingestor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Database  labels
*/}}
{{- define "llm-ingestor.database.selectorLabels" -}}
app.kubernetes.io/component: 'database'
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "llm-ingestor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "llm-ingestor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "llm-ingestor.affinity" -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 100
    podAffinityTerm:
      labelSelector:
        matchLabels:
          {{- include "llm-ingestor.labels" . | nindent 12 }}
          {{- with .Values.podLabels }}
          {{- toYaml . | nindent 12 }}
          {{- end }}
      topologyKey: {{ .Values.affinity.topologyKey }}
{{- end }}