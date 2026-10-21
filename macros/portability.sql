{% macro as_type(expression, data_type) -%}
  {%- set types = {'int64': 'bigint', 'float64': 'double', 'string': 'varchar'} -%}
  {% if target.type == 'duckdb' %}
    try_cast({{ expression }} as {{ types.get(data_type, data_type) }})
  {% else %}
    safe_cast({{ expression }} as {{ data_type }})
  {% endif %}
{%- endmacro %}

{% macro location_part(index) -%}
  {% if target.type == 'duckdb' %}
    nullif(trim(split_part(Location, ',', {{ index + 1 }})), '')
  {% else %}
    nullif(trim(split(Location, ',')[safe_offset({{ index }})]), '')
  {% endif %}
{%- endmacro %}

{% macro regex_contains(expression, pattern) -%}
  {% if target.type == 'duckdb' %}
    regexp_matches({{ expression }}, '{{ pattern }}')
  {% else %}
    regexp_contains({{ expression }}, '{{ pattern }}')
  {% endif %}
{%- endmacro %}

{% macro split_sponsors() -%}
  {% if target.type == 'duckdb' %}
    unnest(string_split(t.sponsors_visible, ',')) as sponsors(sponsor)
  {% else %}
    unnest(split(t.sponsors_visible, ',')) as sponsor
  {% endif %}
{%- endmacro %}
