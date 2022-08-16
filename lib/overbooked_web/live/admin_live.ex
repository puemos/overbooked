defmodule OverbookedWeb.AdminLive do
  use OverbookedWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.table>
      <.tr>
        <.th>Name</.th>
        <.th>Title</.th>
        <.th>Phone</.th>
        <.th>Status</.th>
        <.th></.th>
      </.tr>

      <.tr>
        <.td>
          <.user_inner_td
            avatar_assigns={
              %{
                src:
                  "https://res.cloudinary.com/wickedsites/image/upload/v1636595188/dummy_data/avatar_2_jhs6ww.png"
              }
            }
            label="John Smith"
            sub_label="john.smith@example.com"
          />
        </.td>
        <.td>Engineer</.td>
        <.td class="whitespace-nowrap">+1 0432 677 943</.td>
        <.td>
          <.badge color="success" label="Active" />
        </.td>
        <.td>
          <.link to="/" label="Edit" class="text-primary-600 dark:text-primary-400" />
        </.td>
      </.tr>

      <.tr>
        <.td>
          <.user_inner_td
            avatar_assigns={
              %{
                src:
                  "https://res.cloudinary.com/wickedsites/image/upload/v1636595188/dummy_data/avatar_1_lc8plf.png"
              }
            }
            label="Beth Springs"
            sub_label="beth.springs@example.com"
          />
        </.td>
        <.td>Developer</.td>
        <.td class="whitespace-nowrap">+1 0465 899 443</.td>
        <.td>
          <.badge color="warning" label="Pending" />
        </.td>
        <.td>
          <.link to="/" label="Edit" class="text-primary-600 dark:text-primary-400" />
        </.td>
      </.tr>

      <.tr>
        <.td>
          <.user_inner_td
            avatar_assigns={
              %{
                src:
                  "https://res.cloudinary.com/wickedsites/image/upload/v1636595189/dummy_data/avatar_14_rkiyfa.png"
              }
            }
            label="Peter Knowles"
            sub_label="peter.knowles@example.com"
          />
        </.td>
        <.td>Programmer</.td>
        <.td class="whitespace-nowrap">+1 0472 344 565</.td>
        <.td>
          <.badge color="gray" label="Cancelled" />
        </.td>
        <.td>
          <.link to="/" label="Edit" class="text-primary-600 dark:text-primary-400" />
        </.td>
      </.tr>

      <.tr>
        <.td>
          <.user_inner_td
            avatar_assigns={
              %{
                src:
                  "https://res.cloudinary.com/wickedsites/image/upload/v1604268092/unnamed_sagz0l.jpg"
              }
            }
            label="Sarah Hill"
            sub_label="sarah.hill@example.com"
          />
        </.td>
        <.td>Marketer</.td>
        <.td class="whitespace-nowrap">+1 0429 996 220</.td>
        <.td>
          <.badge color="danger" label="Deleted" />
        </.td>

        <.td>
          <.link to="/" label="Edit" class="text-primary-600 dark:text-primary-400" />
        </.td>
      </.tr>
    </.table>
    """
  end
end
