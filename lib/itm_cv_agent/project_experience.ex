defmodule ItMinds.CvAgent.ProjectExperience do
  defstruct customer_name: nil,
            project_name: nil,
            project_description: nil,
            employee_role_name: nil,
            employee_role_description: nil,
            competencies: [],
            start_date: nil,
            end_date: nil,
            employee_name: nil

  @type t :: %__MODULE__{
          customer_name: String.t(),
          project_name: String.t(),
          project_description: String.t(),
          employee_role_name: String.t(),
          employee_role_description: String.t(),
          competencies: [String.t()],
          start_date: Date.t(),
          end_date: Date.t(),
          employee_name: String.t()
        }
end
