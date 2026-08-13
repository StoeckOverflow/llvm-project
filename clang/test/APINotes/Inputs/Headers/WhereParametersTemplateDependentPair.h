#ifndef WHERE_PARAMETERS_TEMPLATE_DEPENDENT_PAIR_H
#define WHERE_PARAMETERS_TEMPLATE_DEPENDENT_PAIR_H

namespace std {
template <typename, typename> struct pair;
}

template <typename Key, typename Value>
void f(const std::pair<Key, Value> &);

#endif
