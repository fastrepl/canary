defmodule CanaryWeb.HomeLive do
  use CanaryWeb, :live_view

  def render(assigns) do
    ~H"""
    <button class="btn" onclick="add_source.showModal()">
      <span class="hero-plus-solid h-5 w-5" />
    </button>
    <dialog id="add_source" class="modal">
      <div class="modal-box">
        <h3 class="font-bold text-lg">Add new source</h3>

        <div class="p-4 flex flex-col gap-4">
          <select class="select select-bordered w-full max-w-xs">
            <option disabled>Type</option>
            <option>Website</option>
          </select>
          <input type="text" placeholder="Value" class="input input-bordered w-full max-w-xs" />
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
            <th>Type</th>
            <th>Value</th>
            <th>Status</th>
          </tr>
        </thead>

        <tbody>
          <tr>
            <td>Cy Ganderton</td>
            <td>Quality Control Specialist</td>
            <td>Blue</td>
          </tr>
          <tr>
            <td>Hart Hagerty</td>
            <td>Desktop Support Technician</td>
            <td>Purple</td>
          </tr>
          <tr>
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
