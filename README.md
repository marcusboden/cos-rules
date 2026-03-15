# COS Rules Bundle Generator

This repo auto-generates bundled COS rule sets from templates for GitOps publishing.


This setup groups commonly-used alerts into named bundles where each bundle maps to a publishable branch.

## How It Works

1. `config.yaml` defines `bundles` and the `components` each bundle should include.
2. `cutter.py` renders each component template with Cookiecutter into `dest`.
3. The bundle name is used as the output root directory and branch name.
4. Empty `*.rules` files are removed after rendering.

## Configuration Model

Top-level keys in `config.yaml`:

- `dest`: output folder (for example `generated`)
- `vars`: global template variables applied to all bundles
- `bundles`: list of branch bundles

Bundle schema:

```yaml
bundles:
	- name: openstack-yoga
		vars: {}
		components:
			- name: openstack-instance
				vars: {}
			- name: rabbitmq
			- name: ceph
```

Variable precedence is:

1. global `vars`
2. `bundle.vars`
3. `component.vars`

Each render receives `bundle` as the template variable used for output paths
and in-file references.

### Variable Usage Example

Given this `config.yaml` fragment:

```yaml
vars:
	runbook_base_url: "https://runbooks.example.com"

bundles:
	- name: openstack-caracal
		vars:
			severity: warning
		components:
			- name: rabbitmq
				vars:
					connections: 6000
```

You can reference those values in a template file as:

```jinja
summary: "{{ cookiecutter.bundle }} RabbitMQ high connections"
description: "See {{ cookiecutter.runbook_base_url }}/rabbitmq"
severity: "{{ cookiecutter.severity }}"
expr: rabbitmq_connections > {{ cookiecutter.connections }}
```

In that example, `connections` (component) overrides bundle/global values,
`severity` comes from `bundle.vars`, and `runbook_base_url` comes from global `vars`.

## Generate Output

```bash
make all
```

Generated output layout:

```text
generated/
	openstack-yoga/
		prometheus_alert_rules/
		loki_alert_rules/
		grafana_dashboards/
```

## Publish

The bundles are automatically pushed to this repository as branches to be consumed by the cos-configuration-k8s charm.
