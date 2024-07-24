import json
import sys

def load_report(filepath):
    with open(filepath) as f:
        return json.load(f)

def generate_total_report_header():
    return [
        "# Estimated Monthly Summary of Cost Changes💰\n",
        "| Environment | Total Base Cost | Costs with Changes | Costs only Changes |",
        "|-----------------|---------------|-------------|--------------|"
    ]

def generate_project_totals(projects):
    projects_total = []
    for project in projects:
        project_name = project.get('name', 'Unknown project')
        breakdown = project.get('breakdown', {})
        diff = project.get('diff', {})

        total_monthly_cost = float(breakdown.get('totalMonthlyCost', '0'))
        diff_monthly_cost = float(diff.get('totalMonthlyCost', '0'))

        total_cost_with_changes = total_monthly_cost + diff_monthly_cost

        projects_total.append(f"| {project_name} | {total_monthly_cost:.2f} | {total_cost_with_changes:.2f} | +${diff_monthly_cost:.2f} |")
    return projects_total

def generate_cost_details(projects):
    cost_details = ["<details>", "<summary> Monthly Costs Details💰</summary>"]
    for project in projects:
        project_name = project.get('name', 'Unknown project')
        breakdown = project.get('breakdown', {})
        resources = breakdown.get('resources', [])
        diff_resources = project.get('diff', {}).get('resources', [])

        cost_details.append(f"\n\n|RESOURCES IN {project_name.upper()} | COST | DIFF COST |")
        cost_details.append("|--------------|---------------|-----------|")

        resource_groups = {}
        for resource in resources:
            resource_type = resource.get('resourceType', 'Unknown')
            if resource_type not in resource_groups:
                resource_groups[resource_type] = {'resource_names': [], 'costs': []}
            resource_groups[resource_type]['resource_names'].append(resource.get('name', 'Unknown resource'))
            resource_groups[resource_type]['costs'].append(float(resource.get('monthlyCost', '0')))

        diff_resource_groups = {}
        for resource in diff_resources:
            resource_type = resource.get('resourceType', 'Unknown')
            if resource_type not in diff_resource_groups:
                diff_resource_groups[resource_type] = {}
            diff_resource_groups[resource_type][resource.get('name')] = float(resource.get('monthlyCost', '0'))

        for resource_type, group in resource_groups.items():
            resource_names = group['resource_names']
            costs = group['costs']
            diff_costs = [diff_resource_groups.get(resource_type, {}).get(resource_name, 0.0) for resource_name in resource_names]

            resource_names_str = " <br />  ↪︎".join(resource_names)
            costs_str = " <br /> ".join([f"${cost:.2f}" for cost in costs])
            diff_costs_str = " <br /> ".join([f"+${diff_cost:.2f}" for diff_cost in diff_costs])

            cost_details.append(f"| **{resource_type}** <br /> ↪︎{resource_names_str} | {costs_str} | {diff_costs_str} |")
    cost_details.append("</details>")
    return cost_details

def create_markdown(report_file, output_filepath):
    data = load_report(report_file)
    projects = data.get('projects', [])

    total_report = generate_total_report_header()
    projects_total = generate_project_totals(projects)
    cost_details = generate_cost_details(projects)

    total_report.extend(projects_total)
    total_report.extend(cost_details)

    with open(output_filepath, 'w') as f:
        f.write("\n".join(total_report))

if __name__ == "__main__":
    report_file = sys.argv[1]
    create_markdown(report_file, 'output.md')
