{% macro incremental_window() -%}
  {%- set days = var('lookback_days', 7) | int -%}
  {% if days < 0 or days > 365 %}
    {{ exceptions.raise_compiler_error('lookback_days must be between 0 and 365') }}
  {% endif %}
  {% if is_incremental() %}
    where _load_time >= (
      select coalesce(max(_load_time), timestamp '1900-01-01')
      {% if target.type == 'duckdb' %}
        - interval '{{ days }} days'
      {% else %}
        - interval {{ days }} day
      {% endif %}
      from {{ this }}
    )
  {% endif %}
{%- endmacro %}

{% macro latest_per_key(columns) -%}
  qualify row_number() over (
    partition by {{ columns | join(', ') }}
    order by _load_time desc
  ) = 1
{%- endmacro %}
