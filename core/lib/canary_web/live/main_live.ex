defmodule CanaryWeb.MainLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <button class="btn" onclick="add_source.showModal()">
      <span class="hero-plus-solid h-5 w-5" />
    </button>
    <dialog id="add_source" class="modal">
      <div class="modal-box">
        <h3 class="font-bold text-lg">Add source here!</h3>

        <div class="p-4">
          <input type="text" placeholder="Type here" class="input input-bordered w-full max-w-xs" />
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>
    </dialog>

    <div class="overflow-x-auto">
      <table class="table">
        <thead>
          <tr>
            <th></th>
            <th>Name</th>
            <th>Job</th>
            <th>Favorite Color</th>
          </tr>
        </thead>

        <tbody>
          <tr>
            <th>1</th>
            <td>Cy Ganderton</td>
            <td>Quality Control Specialist</td>
            <td>Blue</td>
          </tr>
          <tr>
            <th>2</th>
            <td>Hart Hagerty</td>
            <td>Desktop Support Technician</td>
            <td>Purple</td>
          </tr>
          <tr>
            <th>3</th>
            <td>Brice Swyre</td>
            <td>Tax Accountant</td>
            <td>Red</td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, input: "", result: nil)}
  end
end
