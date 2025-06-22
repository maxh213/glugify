export function get_time_microseconds() {
  return Math.floor(performance.now() * 1000);
}