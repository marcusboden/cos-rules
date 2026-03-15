from pathlib import Path

from cookiecutter.main import cookiecutter
import yaml


def cleanup_empty_files(output_dir):
    """Remove empty .rules files from the generated output."""
    if not output_dir:
        return

    output_path = Path(output_dir)
    if not output_path.exists():
        return

    for rules_file in output_path.rglob("*.rules"):
        if rules_file.is_file() and not rules_file.read_text().strip():
            print(f"Removing empty file: {rules_file}")
            rules_file.unlink()


def render_bundle(bundle, global_vars, output_dir):
    """Render all component templates for a single bundle/branch."""
    bundle_name = bundle.get("name")
    if not bundle_name:
        raise ValueError("Each bundle entry requires a non-empty 'name'.")

    bundle_vars = global_vars.copy()
    print(bundle)
    bundle_vars.update(bundle.get("vars", {}))

    # bundle_name is the canonical template variable for branch grouping.
    bundle_vars["bundle"] = bundle_name

    for component in bundle.get("components", []):
        component_name = component.get("name")
        if not component_name:
            raise ValueError(
                f"Bundle '{bundle_name}' has a component without a 'name'."
            )

        component_vars = bundle_vars.copy()
        component_vars.update(component.get("vars", {}))

        cookiecutter(
            "templates",
            no_input=True,
            extra_context=component_vars,
            directory=component_name,
            overwrite_if_exists=True,
            output_dir=output_dir,
        )


def main():
    with open("config.yaml") as config_fd:
        cfg_data = yaml.safe_load(config_fd) or {}

    output_dir = cfg_data.get("dest", "generated")
    global_vars = cfg_data.get("vars", {})
    bundles = cfg_data.get("bundles", [])

    if not bundles:
        raise ValueError("config.yaml must define at least one entry under 'bundles'.")

    for bundle in bundles:
        render_bundle(bundle, global_vars, output_dir)

    cleanup_empty_files(output_dir)


if __name__ == "__main__":
    main()
