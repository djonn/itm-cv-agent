defmodule ItMinds.CvAgentWeb.Logo do
  @moduledoc """
  It Minds logo component.

  Renders the It Minds logo as inline SVG.

  ## Usage

      <ItMinds.CvAgentWeb.Logo.logo />
      <ItMinds.CvAgentWeb.Logo.logo class="h-12 w-auto" color="#EC407A" />

  """
  use Phoenix.Component

  attr :class, :string, default: "h-10 w-auto"
  attr :color, :string, default: "#EC407A"

  def logo(assigns) do
    ~H"""
    <svg
      width="1524"
      height="702.46"
      viewBox="0 0 1524 702.46"
      class={@class}
      style={["color:", @color]}
      xmlns="http://www.w3.org/2000/svg"
    >
      <defs>
        <clipPath id="clip-It_minds_logo_pink">
          <rect width="1524" height="702.46"></rect>
        </clipPath>
      </defs>
      <g id="It_minds_logo_pink" data-name="It minds logo pink" clip-path="url(#clip-It_minds_logo_pink)">
        <g id="Group_153" data-name="Group 153" transform="translate(0 -645.001)">
          <rect id="Rectangle_3" data-name="Rectangle 3" width="102.531" height="92.067" transform="translate(0.052 645.001)" fill="currentColor"></rect>
          <rect id="Rectangle_1" data-name="Rectangle 1" width="102.531" height="283.947" transform="translate(508.426 1061.867)" fill="currentColor"></rect>
          <rect id="Rectangle_2" data-name="Rectangle 2" width="102.531" height="92.067" transform="translate(508.426 946.863)" fill="currentColor"></rect>
          <path id="Path_1" data-name="Path 1" d="M587.584,257.916q-1.622-.043-3.252-.044a119.4,119.4,0,0,0-85.858,36.275V257.872H395.944V449.751l102.53,92.067V394.759a42.931,42.931,0,0,1,42.094-42.922c24.066-.459,43.764,19.7,43.764,43.769V541.818H686.864V361.237c0-55.5-43.795-101.843-99.281-103.322" transform="translate(244.13 803.997)" fill="currentColor"></path>
          <path id="Path_2" data-name="Path 2" d="M380.029,257.916q-1.622-.043-3.253-.044a119.533,119.533,0,0,0-94.193,45.8,119.753,119.753,0,0,0-180.052-9.527V257.872H0V449.751l102.531,92.067V393.551c0-24.072,19.7-44.229,43.767-43.77A42.93,42.93,0,0,1,188.389,392.7V541.818H290.92V392.7a42.923,42.923,0,0,1,42.771-42.928c23.7-.087,43.085,20.077,43.085,43.778V541.818H479.31V361.244c0-55.507-43.795-101.849-99.28-103.328" transform="translate(0 803.997)" fill="currentColor"></path>
          <path id="Path_3" data-name="Path 3" d="M933.909,341.515l.05,12.879h88.16v-12.95a78.18,78.18,0,0,0-49.96-73.126,164.4,164.4,0,0,0-58.56-10.447c-67.87,0-122.893,38.777-122.893,86.61a63.212,63.212,0,0,0,4.889,24.265c7.18,17.378,21.555,30.791,39.093,37.571l90.444,34.959a17.426,17.426,0,0,1,8.589,6.866l.66,1.019c7.087,10.928.143,25.918-12.853,26.8q-.649.043-1.31.044H899.235a19.148,19.148,0,0,1-19.148-19.152V443.972H792.056a62.28,62.28,0,0,0-1.35,12.881c0,47.833,55.023,86.611,122.893,86.611s122.893-38.778,122.893-86.611a63.224,63.224,0,0,0-4.889-24.265c-7.242-17.525-21.865-30.958-39.658-37.516L888.864,357.09a17.4,17.4,0,0,1-8.591-6.865l-.66-1.017c-7.084-10.928-.141-25.92,12.853-26.8.434-.029.872-.045,1.313-.045h20.98a19.152,19.152,0,0,1,19.15,19.152" transform="translate(487.53 803.996)" fill="currentColor"></path>
          <path id="Path_4" data-name="Path 4" d="M882.924,187.346v399.6H780.393V565.211a75.3,75.3,0,0,1-53.017,21.738A133.461,133.461,0,0,1,593.916,453.486V428.974A133.461,133.461,0,0,1,727.377,295.513a75.293,75.293,0,0,1,53.017,21.738v-129.9ZM780.393,455.854V420.631a42.511,42.511,0,0,0-85.022,0v35.223a42.511,42.511,0,1,0,85.022,0" transform="translate(366.194 760.512)" fill="currentColor"></path>
          <path id="Path_5" data-name="Path 5" d="M322.781,374.1V294.593c-63.088,28.7-61.713-15.333-61.713-15.333V186.051h-.11l55.8-.826v-74H260.986V0H156.528V111.963H0V291.347L102.533,393.878V185.784h54V289.051a104.888,104.888,0,0,0,166.255,85.055Z" transform="translate(0 645)" fill="currentColor"></path>
        </g>
      </g>
    </svg>
    """
  end
end