import json
import sys

report_file = sys.argv[1]

with open(report_file) as f:
    data = json.load(f)

projects = data.get('projects', [])

total_report = []
cost_details = []
projects_total=[]

#Crear Tabla principal para el resumen total
total_report.append("# Estimated Monthly Summary of Cost Changes💰\n")
total_report.append("| Environment | Baseline cost | Usage cost | Total change |")
total_report.append("|-----------------|---------------|-------------|--------------|")

# crear dropdown para detalle de costos por proyecto/entorno
cost_details.append("<details>")
cost_details.append("<summary> Monthly Costs Details💰</summary>")

# Crear una tabla por proyecto-entorno
for project in projects:
    project_name = project.get('name', 'Unknown project')
    #datos en breakdown
    breakdown = project.get('breakdown', {})
    total_monthly_cost = float(breakdown.get('totalMonthlyCost', '0'))
    total_monthly_usage_cost = float(breakdown.get('totalMonthlyUsageCost', '0'))
    #datos en diff
    diff = project.get('diff', {})
    diff_monthly_cost = float(diff.get('totalMonthlyCost', '0'))
    diff_monthly_usage_cost = float(diff.get('totalMonthlyUsageCost', '0'))
    total_change = float(diff_monthly_cost) + float(diff_monthly_usage_cost)

    projects_total.append(f"| {project_name} |  {total_monthly_cost:.2f} (+${diff_monthly_cost:.2f}) | {total_monthly_usage_cost:.2f} (+${diff_monthly_usage_cost:.2f}) | +${total_change:.2f} |")

    #Datos de recursos
    resources = breakdown.get('resources', [])
    diff_resources = diff.get('resources', [])

    cost_details.append(f"\n\n|RESOURCES IN {project_name.upper()} | COST | DIFF COST |")
    cost_details.append("|--------------|---------------|-----------|")

    #agrupar recursos por tipo de recurso en breakdown
    resource_groups = {}
    for resource in resources:
        resource_type = resource.get('resourceType', 'Unknown')
        if resource_type not in resource_groups:
            resource_groups[resource_type] = {
                'resource_names': [],
                'costs': [],
            }
        resource_groups[resource_type]['resource_names'].append(resource.get('name', 'Unknown resource'))
        resource_groups[resource_type]['costs'].append(float(resource.get('monthlyCost', '0')))
        print(resource_groups)

    # #agrupar recursos por tipo de recurso en diff
    diff_resource_groups = {}
    for resource in diff_resources:
        resource_type = resource.get('resourceType', 'Unknown')
        if resource_type not in diff_resource_groups:
            diff_resource_groups[resource_type] = {}
        diff_resource_groups[resource_type][resource.get('name')] = float(resource.get('monthlyCost', '0'))
        print(diff_resource_groups)

    # Generar los rows con lista de recursos en cada resourceType
    for resource_type, group in resource_groups.items():
        resource_names = group['resource_names']
        costs = group['costs']
        diff_costs = []

        for resource_name in resource_names:
            diff_cost = diff_resource_groups.get(resource_type, {}).get(resource_name, 0.0)
            diff_costs.append(diff_cost)

        # pasar listas a cadenas con salto de línea <br />
        resource_names_str = " <br />  ↪︎".join(resource_names)
        costs_str = " <br /> ".join([f"${cost:.2f}" for cost in costs])
        diff_costs_str = " <br /> ".join([f"+${diff_cost:.2f}" for diff_cost in diff_costs])

        cost_details.append(f"| **{resource_type}** <br /> ↪︎{resource_names_str} | {costs_str} | {diff_costs_str} |")
cost_details.append("</details>")

total_report.extend(projects_total)
total_report.extend(cost_details)

# crear el markdown
with open('output.md', 'w') as f:
    f.write("\n".join(total_report))
