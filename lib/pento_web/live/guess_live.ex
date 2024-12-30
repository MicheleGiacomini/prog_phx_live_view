defmodule PentoWeb.GuessLive do
  use PentoWeb, :live_view

  @max_guess 10
  @max_tries :math.ceil(:math.log2(@max_guess))

  def mount(_params, _session, socket) do
    s =
      socket
      |> assign_correct_guess()
      |> assign(score: 0, message: "Make a guess:", guesses: 0, max_guess: @max_guess)

    {:ok, s}
  end

  def render(assigns) do
    ~H"""
    <h1>Your score: {@score}</h1>
    <h2>{@message}</h2>
    <br />
    <h2>
      <.link
        :for={n <- 1..@max_guess}
        phx-click="guess"
        phx-value-number={n}
        class="bg-blue-500 hover:bg-blue-700
    text-white font-bold py-2 px-4 border border-blue-700 rounded m-1"
      >
        {n}
      </.link>
    </h2>
    """
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    if guess == "#{socket.assigns.correct}" do
      s =
        socket
        |> assign_correct_guess()
        |> assign(
          message: "Congratulations! You guessed correclty.",
          score: socket.assigns.score + calc_score(socket.assigns.guesses),
          guesses: 0
        )

      {:noreply, s}
    else
      guesses = socket.assigns.guesses + 1

      message =
        if guess < socket.assigns.correct,
          do: "Your guess #{guess} was low. Try again!",
          else: "Your guess #{guess} was high. Try again!"

      s =
        socket
        |> assign(
          guesses: guesses,
          message: message
        )

      {:noreply, s}
    end
  end

  defp calc_score(guesses) do
    if guesses <= @max_tries do
      :math.pow(2, @max_tries - guesses)
    else
      -:math.pow(2, guesses - @max_tries - 1)
    end
  end

  defp assign_correct_guess(socket) do
    correct = :rand.uniform(@max_guess)
    assign(socket, correct: correct)
  end
end
